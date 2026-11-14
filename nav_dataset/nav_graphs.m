% %% nav_graphs.m — generates summary graphs from system_output.json
% Run this in the same folder as system_output.json.
% Produces 4 subplots: class distribution, decision distribution,
% distance histogram, and detections per camera. Saves as a PNG.

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

fig = figure('Color', 'w', 'Position', [100 100 1000 700]);

% --- 1. Object class distribution ---
subplot(2,2,1);
[c, catNames] = groupcounts(classes);
bar(categorical(catNames), c, 'FaceColor', [0.30 0.45 0.69]);
title('Detected Object Class Distribution');
ylabel('Count');

% --- 2. Navigation decision distribution ---
subplot(2,2,2);
[d, decNames] = groupcounts(decisions);
bar(categorical(decNames), d, 'FaceColor', [0.87 0.52 0.32]);
title('Navigation Decision Distribution');
ylabel('Count');

% --- 3. Distance histogram ---
subplot(2,2,3);
histogram(distances, 20, 'FaceColor', [0.33 0.66 0.41]);
title('Ultrasonic Distance Distribution');
xlabel('Distance (m)'); ylabel('Frequency');

% --- 4. Detections per camera ---
subplot(2,2,4);
[cc, camNames] = groupcounts(cameras);
bar(categorical(camNames), cc, 'FaceColor', [0.77 0.31 0.32]);
title('Detections per Camera Source');
ylabel('Count');

sgtitle('Smart Navigation Assist — Dataset Summary');

saveas(fig, 'dataset_graphs.png');
fprintf('Graphs saved to: %s\n', fullfile(pwd, 'dataset_graphs.png'));
