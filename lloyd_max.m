% Lloyd-Max Αλγόριθμος
function [xq, centers, D] = Lloyd_max(x, N, min_value, max_value)
 
    % Αρχικοποίηση ομοιόμορφων παραμέτρων
    L = 2^N;
    delta = (max_value - min_value) / L;
    centers = linspace(min_value + delta / 2, max_value - delta / 2, L);
    boundaries = [min_value, (centers(1:end-1) + centers(2:end)) / 2, max_value];
    
    D = []; % Διάνυσμα που κρατάει τις παραμορφώσεις
    convergence_rates = []; % Διάνυσμα που κρατάει τις διαφορές παραμορφώσεων
 
    % Επαναλήψεις
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
        
        % Υπολογισμός διαφοράς παραμόρφωσης (για τη σύγκλιση)
        if length(D) > 1
            convergence_rates = [convergence_rates, abs(D(end) - D(end-1))];
        end
        
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
 
 
% Αρχικοποίηση Παραμέτρων Σήματος
F = 4;                   % Συχνότητα αναλογικού σήματος (Hz)
Fs = 50;                 % Συχνότητα δειγματοληψίας (Hz)
Ts = 1/Fs;               % Περίοδος δειγματοληψίας
t = 0:Ts:1;              % Βήμα δειγματοληψίας
x = sin(2*pi*F*t);       % Αναλογικό σήμα
 
% Παράμετροι Ομοιόμορφου Κβαντισμού
N = 3;                   % Αριθμός bits
min_value = -1;          % Ελάχιστη αποδεκτή υιμή του σήματος εισόδου
max_value = 1;           % Μέγιστη αποδεκτή υιφή του σήματος εισόδου
 
% Κλήση Συνάρτησης
[xq, centers, D] = Lloyd_max(x, N, min_value, max_value);
 
% Plot
figure;
 
% Corrected Plot Section

% Plot 1: Αρχικό και Κβαντισμένο Σήμα
subplot(2, 2, 1);
plot(t, x, 'b', 'LineWidth', 1.5); hold on;
stairs(t, xq, 'r', 'LineWidth', 1.2);
title('Original vs. Quantized Signal');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Original Signal', 'Quantized Signal');
grid on;

% Plot 2: Κέντρα Κβαντισμού
subplot(2, 2, 2);
stem(centers, ones(size(centers)), 'g', 'LineWidth', 1.5);
title('Quantization Centers');
xlabel('Amplitude');
ylabel('Indicator');
grid on;

% Plot 3: Παραμόρφωση σε κάθε επανάληψη
subplot(2, 2, 3);
plot(1:length(D), D, '-o', 'LineWidth', 1.5);
title('Distortion Over Iterations');
xlabel('Iteration');
ylabel('Mean Squared Distortion');
grid on;

% Plot 4: Σύγκλιση Παραμόρφωσης
% Calculate convergence rates directly here
convergence_rates = abs(diff(D));
subplot(2, 2, 4);
plot(2:length(D), convergence_rates, '-s', 'LineWidth', 1.5);
title('Distortion Convergence');
xlabel('Iteration');
ylabel('|D_{i} - D_{i-1}|');
grid on;
