% Lloyd-Max Αλγόριθμος
function [xq, centers, D] = Lloyd_max(x, N, min_value, max_value)

    % Αρχικοποίηση ομοιόμορφων παραμέτρων
    L = 2^N;
    delta = (max_value - min_value) / L;
    centers = linspace(min_value + delta / 2, max_value - delta / 2, L);
    boundaries = [min_value, (centers(1:end-1) + centers(2:end)) / 2, max_value];
    
    D = []; % Διάνυσμα που κρατάει τις παραμορφώσεις

    while true
        % Βήμα 1: Υπολογισμός ορίων ζωνών κβαντισμού
        xq = zeros(size(x));
        for i = 1:length(x)
            for j = 1:length(boundaries) - 1
                if x(i) >= boundaries(j) && x(i) < boundaries(j + 1)
                    xq(i) = centers(j);
                    break;
                end
            end
        end
        
        % Βήμα 2: Υπολογισμός παραμόρφωσης
        distortion = mean((x - xq).^2);
        D = [D, distortion];
        
        % Βήμα 3: Ενημέρωση επιπέδων κβαντισμού 
        new_centers = zeros(1, L);
        counts = zeros(1, L);
        for i = 1:length(x)
            for j = 1:L
                if xq(i) == centers(j)
                    new_centers(j) = new_centers(j) + x(i);
                    counts(j) = counts(j) + 1;
                    break;
                end
            end
        end
        
        for j = 1:L
            if counts(j) > 0
                new_centers(j) = new_centers(j) / counts(j);
            else
                new_centers(j) = centers(j);
            end
        end
        
        % Σύγκλιση για να σταματήσει η λούπα 
        if length(D) > 1 && abs(D(end) - D(end-1)) < 1e-6
            break;
        end
        
        centers = new_centers;
        boundaries = [min_value, (centers(1:end-1) + centers(2:end)) / 2, max_value];
    end
end

clear; clc;

% Φόρτωση του αρχείου ήχου
[y, fs] = audioread('speech.wav');
y = y / max(abs(y));

% Παράμετροι
min_value = -1;
max_value = 1;
epsilon = 1e-6; % Threshold σύγκλισης
bits = [2, 4, 8]; % Bit-depth
colors = ['r', 'g', 'b']; % Χρώματα για το Plot

% Αποθήκευση τιμών SQNR
SQNR_all = cell(length(bits), 1);

figure;
hold on;

for idx = 1:length(bits)
    N = bits(idx);
    
    % Κλήση Συνάρτησης
    [xq, centers, D] = Lloyd_max(y, N, min_value, max_value);
    
    % Υπολογισμός SQNR σε κάθε επανάληψη
    SQNR = 10 * log10(mean(y.^2) ./ D);
    
    % Αποθήκευση τιμών SQNR για plot
    SQNR_all{idx} = SQNR;
    
    % Plot SQNR
    plot(1:length(SQNR), SQNR, 'Color', colors(idx), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('N = %d', N));
end

% Plot
xlabel('Iteration');
ylabel('SQNR (dB)');
title('SQNR Evolution for Lloyd-Max Algorithm');
legend show;
grid on;
hold off;