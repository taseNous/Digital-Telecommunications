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

% Φόρτωση αρχείου ήχου
[y, fs] = audioread('speech.wav');
y = y / max(abs(y)); % Κανονικοποίηση σήματος στο διάστημα [-1, 1]

% Παράμετροι
min_value = -1;
max_value = 1;
bits = [2, 4, 8];

% Αρχικοποίηση πίνακα για αποθήκευση τιμών SQNR για κάθε Ν
SQNR_results = zeros(length(bits), 1);

% Επαναλήψεις για κάθε Ν
for b = 1:length(bits)
    N = bits(b);
    
    % Κλήση συνάρτησης ομοιόμορφου κβαντισμού 
    [xq, ~] = my_quantizer(y, N, min_value, max_value);
    
    % Υπολογισμός SQNR
    signal_power = mean(y(:).^2);
    noise_power = mean((y(:) - xq(:)).^2);
    SQNR_results(b) = 10 * log10(signal_power / noise_power);
end

% Plot για τα διαφορετικά Ν
figure;
plot(bits, SQNR_results, '-o', 'LineWidth', 1.5, 'MarkerSize', 8);
xlabel('Quantization Levels (N bits)');
ylabel('SQNR (dB)');
title('SQNR vs Quantization Levels');
grid on;