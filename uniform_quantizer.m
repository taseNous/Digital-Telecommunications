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

% Αρχικοποίηση Παραμέτρων Σήματος
F = 4;                   % Συχνότητα αναλογικού σήματος (Hz)
Fs = 50;                 % Συχνότητα δειγματοληψίας (Hz)
Ts = 1/Fs;               % Περίοδος δειγματοληψίας
t = 0:Ts:1;              % Βήμα δειγματοληψίας
x = sin(2*pi*F*t);       % Αναλογικό σήμα

% Παράμετροι Ομοιόμορφου Κβαντισμού
N = 3;                   % Αριθμός bits
min_value = -1;          % Ελάχιστη αποδεκτή υιμή του σήματος εισόδου
max_value = 1;           % Μέγιστη αποδεκτή υιμή του σήματος εισόδου

% Κλήση Συνάρτησης
[xq, centers] = my_quantizer(x, N, min_value, max_value);

% Υπολογισμός Δεικτών Κβαντισμού
delta = (max_value - min_value) / (2^N);  % Βήμα κβαντισμού
xq_indices = round((xq - min_value) / delta);  % Ανάκτηση δεικτών κβαντισμού
xq_indices = max(min(xq_indices, 2^N - 1), 0); % Περιορισμός στις επιτρεπτές τιμές

% Plot
figure;

% Αρχικό σήμα και δείγματα
subplot(4, 1, 1);
plot(t, x, 'b', 'LineWidth', 1.5); hold on;
stem(t, x, 'r', 'LineWidth', 1.2); grid on;
title('Original Signal and Samples');
xlabel('Time (s)'); ylabel('Amplitude');
legend('Original Signal', 'Sampled Points');

% Κβαντισμένο σήμα
subplot(4, 1, 2);
stem(t, xq, 'g', 'LineWidth', 1.5); grid on;
title('Quantized Signal');
xlabel('Time (s)'); ylabel('Amplitude');
legend('Quantized Values');

% Δείκτες κβαντισμού
subplot(4, 1, 3);
stem(t, xq_indices, 'k', 'LineWidth', 1.5); grid on;
title('Quantization Indices');
xlabel('Time (s)'); ylabel('Indices');
legend('Quantization Levels');

% Δυαδική Κωδικοποίηση
binary_encoded = dec2bin(xq_indices, N);
subplot(4, 1, 4);
hold on;
for i = 1:length(t)
    text(t(i), xq_indices(i), binary_encoded(i, :), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', ...
        'FontSize', 8, 'Color', 'blue');
end
stem(t, xq_indices, 'k', 'LineWidth', 1.5); grid on;
title('Binary Encoding of Quantization Indices');
xlabel('Time (s)'); ylabel('Indices');
legend('Binary Encoded');