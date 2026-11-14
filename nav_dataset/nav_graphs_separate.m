%% nav_graphs_separate.m — generates 4 INDIVIDUAL graph windows
% Unlike nav_graphs.m (which combines everything into one 2x2 subplot),
% this script opens a separate figure for each graph and saves each
% as its own PNG file. Run this in the same folder as system_output.json.

clear; clc; close all;

data = jsondecode(fileread('system_output.json'));
n = numel(data);

classes   = strings(n,1);
decisions = strings(n,1);
distances = zeros(n,1);
cameras   = strings(n,1);

for i = 1:n
    classes(i)   = data(i).detected_class;
    decisions(i) = data(i).navigation_decision;
    distances(i) = data(i).distance_m;
    cameras(i)   = data(i).camera_source;
end

%% --- Graph 1: Object class distribution ---
fig1 = figure('Name', 'Object Class Distribution', 'Color', 'w', 'Position', [50 500 600 450]);
[c, catNames] = groupcounts(classes);
bar(categorical(catNames), c, 'FaceColor', [0.30 0.45 0.69]);
title('Detected Object Class Distribution');
xlabel('Object Class'); ylabel('Count');
grid on;
saveas(fig1, 'graph1_object_classes.png');

%% --- Graph 2: Navigation decision distribution ---
fig2 = figure('Name', 'Navigation Decision Distribution', 'Color', 'w', 'Position', [700 500 600 450]);
[d, decNames] = groupcounts(decisions);
bar(categorical(decNames), d, 'FaceColor', [0.87 0.52 0.32]);
title('Navigation Decision Distribution');
xlabel('Decision'); ylabel('Count');
grid on;
saveas(fig2, 'graph2_navigation_decisions.png');

%% --- Graph 3: Ultrasonic distance histogram ---
fig3 = figure('Name', 'Ultrasonic Distance Distribution', 'Color', 'w', 'Position', [50 20 600 450]);
histogram(distances, 20, 'FaceColor', [0.33 0.66 0.41]);
title('Ultrasonic Distance Distribution');
xlabel('Distance (m)'); ylabel('Frequency');
grid on;
saveas(fig3, 'graph3_distance_histogram.png');

%% --- Graph 4: Detections per camera ---
fig4 = figure('Name', 'Detections per Camera', 'Color', 'w', 'Position', [700 20 600 450]);
[cc, camNames] = groupcounts(cameras);
bar(categorical(camNames), cc, 'FaceColor', [0.77 0.31 0.32]);
title('Detections per Camera Source');
xlabel('Camera'); ylabel('Count');
grid on;
saveas(fig4, 'graph4_camera_source.png');

fprintf('Saved 4 separate graphs:\n');
fprintf('  %s\n', fullfile(pwd, 'graph1_object_classes.png'));
fprintf('  %s\n', fullfile(pwd, 'graph2_navigation_decisions.png'));
fprintf('  %s\n', fullfile(pwd, 'graph3_distance_histogram.png'));
fprintf('  %s\n', fullfile(pwd, 'graph4_camera_source.png'));
