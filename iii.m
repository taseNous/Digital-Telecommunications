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

% Ομοιόμορφος Κβαντιστής 
function [xq, centers] = my_quantizer(x, N, min_value, max_value)

    % Διασφάλιση ότι min_value < max_value
    assert(min_value < max_value, 'min_value must be smaller than max_value');
    
    % Διασφάλιση ότι N > 0
    assert(N > 0 && floor(N) == N, 'N must be a positive integer');
    
    % Βήμα 1: Περιορισμός δυναμικής περιοχής του σήματος στις τιμές [min_value,
    % max_value]
    x_confined = max(min(x, max_value), min_value);
    
    % Βήμα 2: Υπολογισμός του βήματος κβαντισμού Δ και των κεντρών κάθε
    % περιοχής
    L = 2^N;                 % Αριθμός επιπέδων κβαντισμού
    delta = (max_value - min_value) / L;
    centers = min_value + (0:L-1) * delta;
    
    % Βήμα 3: Εύρεση περιοχής που ανήκει το κάθε δείγμα
    epsilon = 1e-12; % Μικρό e για αποφυγή σφάλματα στρογγυλοποίησης 
    xq_indices = round((x_confined - min_value + epsilon) / delta);
    xq_indices = max(min(xq_indices, L-1), 0);                        
    
    % Βήμα 4: xq ως δείκτης στο διάνυσμα centers
    xq = centers(xq_indices + 1);
    xq = reshape(xq, size(x));
    
end

clear; clc;

% Φόρτψση ήχου
[y, fs] = audioread('speech.wav');
y = y / max(abs(y));

% Παράμετροι
min_value = -1;
max_value = 1;
bits = [2, 4, 8];

% Επιλογές για το plot
line_styles = {'-', '--', ':'};
colors = ['r', 'g', 'b'];
lloyd_colors = ['m', 'c', 'y'];

figure;
hold on;

% Λούπα για τα Ν
for idx = 1:length(bits)
    N = bits(idx);

    % Κλήση συνάρτησης ομοιόμορφου κβαντισμού
    [xq_uniform, ~] = my_quantizer(y, N, min_value, max_value);

    % Κλήση συνάρτησης Lloyd-Max
    [xq_lloyd, ~, ~] = Lloyd_max(y, N, min_value, max_value);

    % Αρχικός ήχος
    fprintf('Playing original signal...\n');
    sound(y, fs);
    pause(length(y) / fs + 1); % Αναμονή μέχρι να τελειώσει ο ήχος

    fprintf('Playing uniform quantized signal for N = %d...\n', N);
    sound(xq_uniform, fs);
    pause(length(xq_uniform) / fs + 1);

    fprintf('Playing Lloyd-Max quantized signal for N = %d...\n', N);
    sound(xq_lloyd, fs);
    pause(length(xq_lloyd) / fs + 1);

    % Plot κυματομορφών
    subplot(length(bits), 1, idx);
    plot(y, 'k', 'LineWidth', 1.2, 'DisplayName', 'Original');
    hold on;
    plot(xq_uniform, [colors(idx) line_styles{1}], 'LineWidth', 1, ...
         'DisplayName', sprintf('Uniform N = %d', N));
    plot(xq_lloyd, [lloyd_colors(idx) line_styles{2}], 'LineWidth', 1, ...
         'DisplayName', sprintf('Lloyd-Max N = %d', N));
    title(sprintf('Waveform Comparison for N = %d', N));
    xlabel('Sample Index');
    ylabel('Amplitude');
    legend;
    grid on;
end

hold off;
sgtitle('Waveform Comparisons for Original and Quantized Signals');