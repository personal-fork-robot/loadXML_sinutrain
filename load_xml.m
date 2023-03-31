clear;
clc;

fid = fopen('Session0331.xml', 'r');
data = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
data = data{1};

% 查找包含key、id和name信息的行，并解析
keys = {};
ids = {};
names = {}; % ids和names一一对应
plot_data = [];
f_values_before = zeros(1, 12);
% 使用正则表达式提取f字段的值
f_order = {'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12'}; % 按照f1到f12的顺序
f_values = zeros(1, length(f_order));
cnt = 1;
for i = 1:length(data)
    if contains(data{i}, '<dataSignal')
        % 解析key
        key = regexp(data{i}, 'key="(\w+)"', 'tokens');
        key = key{1}{1};
        keys{end+1} = key;

        % 解析id
        id = regexp(data{i}, 'id="(\w+)"', 'tokens');
        id = id{1}{1};
        ids{end+1} = id;

        % 解析name
        name = regexp(data{i}, 'name="([^"]+)"', 'tokens');
        name = name{1}{1};
        names{end+1} = name;
    end

    time_values = 0;
    if contains(data{i}, '<rec')
        % 解析f属性和time
        time_value = regexp(data{i}, 'time="([^"]+)"', 'tokens');
        time_values = str2double(time_value{1});
        
        for j = 1:length(f_order)
            f_pattern = [f_order{j}, '="([^"]*)"'];
            f_match = regexp(data{i}, f_pattern, 'tokens', 'once');
            if ~isempty(f_match)
                f_values(j) = str2double(f_match);
            else
                % 字段缺失，将上一次的值复制到这一次
                f_values(j) = f_values_before(j);
            end
        end
        f_values_before = f_values;
        plot_data(cnt, 1: length(f_values)+1) = [time_values, f_values];
        cnt = cnt + 1;
    end
end
save('result.mat', 'keys', 'ids', 'names');
save('plot_data.mat', 'plot_data');


