%% The ideal soliton distribution

% k is the information 
k = 16;
p = zeros(1,k);
d_axis = 1:k;
for d=1:k
    if d==1
        p(d) = 1 / k;
    else
        p(d) = 1/(d*(d-1));
    end
end

% mean?
E_p = sum((1:k).*p)
p_d1 = p(1)

figure(1)
semilogx(p, 'LineWidth',1)
hold on
xlim([1 k])
ylim([-max(p)*0.2 max(p)*1.2])
xlabel('d');
ylabel('p');
grid on
title('Ideal soliton distribution for k=16')
legend('Ideal')
hold off

%% O deal CDF

p_cdf = zeros(1,k);
for d=1:k
    if d == 1
        p_cdf(d) = p(d);
    else
        p_cdf(d) = p(d)+p_cdf(d-1);
    end
end

% Finding the minimum delta and quantising 
p_cdf_min = 1/(p_cdf(k)-p_cdf(k-1))

p_cdf_quantise = round(p_cdf.* 2^(8)-1);

figure(3)
semilogx(p_cdf_quantise, '.-', 'Color', 'red')
grid on

%% Printing p cdf

fprintf('{');
for d=1:k-1
   fprintf('%i,', p_cdf_quantise(d));
   if(mod(d,8) == 0)
       fprintf("\n");
   end
end
fprintf('%i};\n', p_cdf_quantise(k));

%% Robust soliton dist O1.
tau = zeros(1,k);
delta = 1.992;
c = 0.24;
S = 2;

for d=1:k
    if d <= (round(k/S))-1
        tau(d) = S / (k * d);
    elseif (d == round(k/S))
        tau(d) = (S/k)*log(S/delta);
    else
        tau(d) = 0;
    end
end

Z = sum(p)+sum(tau);
O1 = (p + tau)./Z;
E_p = sum((1:k).*O1)
figure(2)
semilogx(p, '.-', 'Color', 'red')
hold on
semilogx(O1, 'Color', 'green')
title('Robust soliton distribution O1');
semilogx(tau, 'Color', 'blue')
xlabel('d');
ylabel('p');
xlim([1 k]); %k/S+1
ylim([-max(p)*0.2 max(p)*1.2])
grid on
hold off
legend('Ideal','O1','tau')

%% Robust soliton dist O2.
tau = zeros(1,k);
delta = 0.275;
c = 0.123;
S = 2; %c*log(k/delta)*sqrt(k);
ratio = k/S;
spike = (S/k)*log(S/delta);

for d=1:k
    if d <= (round(k/S))-1
        tau(d) = S / (k * d);
    elseif (d == round(k/S))
        tau(d) = (S/k)*log(S/delta);
    else
        tau(d) = 0;
    end
end
spike_tau = tau(round(k/S));
Z = sum(p)+sum(tau);
O2 = (p + tau)./Z;

figure(2)
semilogx(p, '.-', 'Color', 'red')
hold on
semilogx(tau, 'Color', 'green')
title('Robust soliton distribution O2');
semilogx(O2, 'Color', 'blue')
xlabel('d');
ylabel('p');
xlim([1 k]); %k/S+1
ylim([-max(p)*0.2 max(p)*1.2])
grid on
hold off
legend('Ideal','tau','O2')

%% O1 cdf

O1_cdf = zeros(1,k);
Line_q = ones(1,k).*2^(15);
Line = ones(1,k);
for d=1:k
    if d == 1
        O1_cdf(d) = O1(d);
    else
        O1_cdf(d) = O1(d)+O1_cdf(d-1);
    end
end

% Finding the minimum delta and quantising
O1_min_diff = 1/(O1_cdf(k)-O1_cdf(k-1));
O1_cdf_quantise = round(O1_cdf.*2^(9)-1);
figure(3)
semilogx(O1_cdf_quantise, '.-', 'Color', 'red')
hold on
semilogx(Line, 'Color', 'blue')
title('CDF of Robust soliton distribution O1');
xlabel('degree');
ylabel('U');
hold off
grid on

%% Printing O1 cdf

fprintf('{');
for d=1:k-1
   fprintf('%i,', O1_cdf_quantise(d));
   if(mod(d,8) == 0)
       fprintf("\n");
   end
end
fprintf('%i};\n', O1_cdf_quantise(k));

%% O2 cdf

O2_cdf = zeros(1,k);
for d=1:k
    if d == 1
        O2_cdf(d) = O2(d);
    else
        O2_cdf(d) = O2(d)+O2_cdf(d-1);
    end
end

% Finding the minimum delta and quantising 
O2_min_diff = 1/(O2_cdf(k)-O2_cdf(k-1))
O2_cdf_quantise = round(O2_cdf.* 2^(9)-1);

figure(3)
semilogx(O2_cdf_quantise, '.-', 'Color', 'red')
grid on
%% Printing O2 cdf

fprintf('{');
for d=1:k-1
   fprintf('%i,', O2_cdf_quantise(d));
   if(mod(d,8) == 0)
       fprintf("\n");
   end
end
fprintf('%i};\n', O2_cdf_quantise(k));

%% Experiment - Oi, o1, o2...

Packet_loss = [zeros(1,4), ones(1,3).*25, ones(1,3).*50, ones(1,3).*60, ones(1,3).*75, ones(1,3).*85];
O_ideal_recover = [31, 18, 42, 23, 19, 29, 34, 55, 53, 48, 73, 116, 49, 76, 132, 129, 161, 237, 129];
O_1_recover = [20,28,26,31,33,36,35,69,74,73,54,66,73,55,91,141,160,169,160];
O_2_recover = [24, 35, 28, 32, 38, 43, 40, 56, 49, 64, 36, 38, 95, 55, 66, 137, 192, 258, 160];
O_ideal_recover_avr = zeros(1, length(O_ideal_recover));
O_ideal_recover_avr(1:4) = sum(O_ideal_recover(1:4))/4;
O_1_recover_avr = zeros(1, length(O_1_recover));
O_1_recover_avr(1:4) = sum(O_1_recover(1:4))/4;
O_2_recover_avr = zeros(1, length(O_2_recover));
O_2_recover_avr(1:4) = sum(O_2_recover(1:4))/4;
for i=1:(length(Packet_loss)-3)/3
    %fprintf('%i : %i ,',5+(i-1)*3, 5+(i*3)-1);
    O_ideal_recover_avr(5+(i-1)*3 : 5+(i*3)-1) = sum(O_ideal_recover(5+(i-1)*3 : 5+(i*3)-1))/3;
    O_1_recover_avr(5+(i-1)*3 : 5+(i*3)-1) = sum(O_1_recover(5+(i-1)*3 : 5+(i*3)-1))/3;
    O_2_recover_avr(5+(i-1)*3 : 5+(i*3)-1) = sum(O_2_recover(5+(i-1)*3 : 5+(i*3)-1))/3;
end

%%
k_line = 16.*ones(1, length(Packet_loss));

figure(100)
s1 = subaxis(1,3,1, 'Spacing', 0.03, 'Padding', 0.005, 'Margin', 0.08);
plot(Packet_loss, O_ideal_recover, 'o', 'Color', 'red')
hold on
xlabel('Packet loss [%]');
ylabel('Packets transmitted');
xlim([0 85])
ylim([0 260])
plot(Packet_loss, O_ideal_recover_avr, 'Color', 'blue')
plot(Packet_loss, k_line, 'Color', 'black')
legend('O ideal','average', 'K=16')
hold off

s2 = subaxis(1,3,2, 'Spacing', 0.03, 'Padding', 0.005, 'Margin', 0.08);
plot(Packet_loss, O_1_recover, 'o', 'Color', 'red')
hold on
xlabel('Packet loss [%]');
title('Packets transmitted in total to recover all K packets');
xlim([0 85])
ylim([0 260])
plot(Packet_loss, O_1_recover_avr, 'Color', 'blue')
plot(Packet_loss, k_line, 'Color', 'black')
legend('O1','average', 'K=16')
hold off

s3 = subaxis(1,3,3, 'Spacing', 0.03, 'Padding', 0.005, 'Margin', 0.08);

plot(Packet_loss, O_2_recover, 'o', 'Color', 'red')
hold on
xlabel('Packet loss [%]');
xlim([0 85])
ylim([0 260])
plot(Packet_loss, O_2_recover_avr, 'Color', 'blue')
plot(Packet_loss, k_line, 'Color', 'black')
legend('O2','average', 'K=16')
hold off

linkaxes([s1, s2, s3], 'y');
%%

figure(101)
plot(Packet_loss, O_ideal_recover_avr, 'Color', 'red');
hold on
plot(Packet_loss, O_1_recover_avr, 'Color', 'blue');
plot(Packet_loss, O_2_recover_avr, 'Color', 'green');
plot(Packet_loss, k_line, 'Color', 'black'),
title('Average packets transmitted to recover information symbols');
xlabel('Packet loss [%]');
ylabel('Packets transmitted');
xlim([0 85])
ylim([0 250])
grid on
legend('Ideal','O1','O2', 'K=16')
hold off

% Comparison LT and ARQ
%% LT
ms_to_sec = 10^(-3);

% 1 node 10% loss
n_dec_1_10 = [23];
T_dec_1_10 = [8];
n_enc_1_10 = 24;
T_enc_1_10 = 13;
% 2 nodes 10% loss
n_dec_2_10 = [25, 25];
T_dec_2_10 = [8, 8];
n_enc_2_10 = 29;
T_enc_2_10 = 15;
% 4 nodes 10% loss
n_dec_4_10 = [20, 20, 28, 26];
T_dec_4_10 = [7, 9, 12, 11];
n_enc_4_10 = 31;
T_enc_4_10 = 20;
% 8 nodes 10% loss
n_dec_8_10 = [24, 23, 25, 26, 23, 24, 26, 25];
T_dec_8_10 = [9, 9, 9, 16, 8, 9, 10, 18];
n_enc_8_10 = 30;
T_enc_8_10 = 16;
% 16 nodes 10% loss
n_dec_16_10 = [21, 21, 21, 21, 22, 21, 22, 24, 25, 26, 28, 28, 27, 27, 31, 26];
T_dec_16_10 = [7, 7, 8, 9, 10, 10, 10, 10, 11, 10, 11, 12, 11, 12, 11, 11];
n_enc_16_10 = 34;
T_enc_16_10 = 22;

% 1 node 20% loss
n_dec_1_20 = [20];
T_dec_1_20 = [7];
n_enc_1_20 = 23;
T_enc_1_20 = 12;

% 2 nodes 20% loss
n_dec_2_20 = [23, 26];
T_dec_2_20 = [7 ,9];
n_enc_2_20 = 34;
T_enc_2_20 = 18;

% 4 nodes 20% loss
n_dec_4_20 = [21, 24, 28, 28];
T_dec_4_20 = [7, 10, 11, 9];
n_enc_4_20 = 36;
T_enc_4_20 = 20;

% 8 nodes 20% loss
n_dec_8_20 = [20, 20, 22, 23, 22, 23, 26, 37];
T_dec_8_20 = [8, 6, 8, 8, 6, 8, 9, 13];
n_enc_8_20 = 49;
T_enc_8_20 = 29;

% 16 nodes 20% loss
n_dec_16_20 = [22, 20, 24, 23, 21, 25, 25, 23, 21, 26, 27, 24, 32, 30, 36, 38];
T_dec_16_20 = [10, 11, 11, 11, 10, 14, 14, 12, 9, 15, 15, 12, 15, 16, 13, 18];
n_enc_16_20 = 49;
T_enc_16_20 = 36;

% 32 nodes 20% loss
n_dec_32_20 = [20, 21, 20, 22, 23, 20, 23, 23, 22, 21, 21, 24, 21, 22, 23, 26, 24, 23, 27, 27, 21, 23, 24, 21, 24, 27,25,23,24,28,21,31];
T_dec_32_20 = [7, 8, 7, 7, 8, 7, 8, 8, 9, 8, 8, 9, 9, 8, 7, 10, 8, 9, 11, 10, 8, 9, 10, 8, 9, 10, 10, 9, 9, 10, 9, 13];
n_enc_32_20 = 44;
T_enc_32_20 = 25;

% 1 node 40% loss
n_dec_1_40 = 22;
T_dec_1_40 = 9;
n_enc_1_40 = 32;
T_enc_1_40 = 17;

% 2 node 40% loss
n_dec_2_40 = [26, 24];
T_dec_2_40 = [15, 16];
n_enc_2_40 = 48;
T_enc_2_40 = 46;

% 4 nodes 40% loss
n_dec_4_40 = [25, 20, 23, 30];
T_dec_4_40 = [7, 7, 7, 12];
n_enc_4_40 = 50;
T_enc_4_40 = 27;

% 8 ndoes with 40% loss
n_dec_8_40 = [27, 26, 25, 25, 28, 25, 24, 33];
T_dec_8_40 = [12, 10, 10, 10, 12, 9, 8, 12];
n_enc_8_40 = 50;
T_enc_8_40 = 30;

% 16 nodes 40% loss
n_dec_16_40 = [22, 18, 22, 25, 23, 22, 21, 20, 28, 26, 29, 24, 25, 27, 27, 30];
T_dec_16_40 = [8, 6, 6, 9, 7, 7, 8, 8, 12, 9, 10, 10, 11, 11, 8, 12];
n_enc_16_40 = 56;
T_enc_16_40 = 38;

% 1 node 60% loss
n_dec_1_60 = 28;
T_dec_1_60 = 12;
n_enc_1_60 = 60;
T_enc_1_60 = 41;

% 2 nodes 60% loss
n_dec_2_60 = [24, 24];
T_dec_2_60 = [9, 8];
n_enc_2_60 = 60;
T_enc_2_60 = 32;

% 4 nodes 60% loss
n_dec_4_60 = [24, 24, 29, 27];
T_dec_4_60 = [13, 7, 10, 13];
n_enc_4_60 = 70;
T_enc_4_60 = 53;

% 8 nodes 60% loss
n_dec_8_60 = [20, 20, 20, 26, 22, 26, 26, 29];
T_dec_8_60 = [7, 6, 7, 9, 9, 10, 8, 13];
n_enc_8_60 = 69;
T_enc_8_60 = 39;

% 16 nodes 60% loss
n_dec_16_60 = [21, 23, 31, 30, 24, 28, 27, 29, 26, 27, 24, 24, 26, 24, 30, 33];
T_dec_16_60 = [9, 8, 14, 12, 10, 15, 8, 13, 13, 11, 9, 8, 11, 10, 10, 12];
n_enc_16_60 = 107;
T_enc_16_60 = 90;

% Calculate energy for 10% loss

E_tx_1_10_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_1_10*56)/(250*10^3))+T_enc_1_10*ms_to_sec*5.58*10^(-3);
E_tx_2_10_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_2_10*56)/(250*10^3))+T_enc_2_10*ms_to_sec*5.58*10^(-3);
E_tx_4_10_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_4_10*56)/(250*10^3))+T_enc_4_10*ms_to_sec*5.58*10^(-3);
E_tx_8_10_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_8_10*56)/(250*10^3))+T_enc_8_10*ms_to_sec*5.58*10^(-3);
E_tx_16_10_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_16_10*56)/(250*10^3))+T_enc_16_10*ms_to_sec*5.58*10^(-3);

E_rx_1_10_lt = (6.53*10^(-6))*(n_dec_1_10)+(33.8*10^(-3)).*((n_dec_1_10*56)/(250*10^3))+T_dec_1_10*ms_to_sec*5.58*10^(-3);
E_rx_2_10_lt = zeros(1,length(n_dec_2_10));
for i=1:length(n_dec_2_10)
    E_rx_2_10_lt(i) = (6.53*10^(-6))*(n_dec_2_10(i))+(33.8*10^(-3)).*((n_dec_2_10(i)*56)/(250*10^3))+T_dec_2_10(i)*ms_to_sec*5.58*10^(-3);
end
E_rx_4_10_lt = zeros(1,length(n_dec_4_10));
for i=1:length(n_dec_4_10)
    E_rx_4_10_lt(i) = (6.53*10^(-6))*(n_dec_4_10(i))+(33.8*10^(-3)).*((n_dec_4_10(i)*56)/(250*10^3))+T_dec_4_10(i)*ms_to_sec*5.58*10^(-3);
end
E_rx_8_10_lt = zeros(1,length(n_dec_8_10));
for i=1:length(n_dec_8_10)
    E_rx_8_10_lt(i) = (6.53*10^(-6))*(n_dec_8_10(i))+(33.8*10^(-3)).*((n_dec_8_10(i)*56)/(250*10^3))+T_dec_8_10(i)*ms_to_sec*5.58*10^(-3);
end
E_rx_16_10_lt = zeros(1,length(n_dec_16_10));
for i=1:length(n_dec_16_10)
    E_rx_16_10_lt(i) = (6.53*10^(-6))*(n_dec_16_10(i))+(33.8*10^(-3)).*((n_dec_16_10(i)*56)/(250*10^3))+T_dec_16_10(i)*ms_to_sec*5.58*10^(-3);
end

% Calculate energy for 20% loss
E_tx_1_20_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_1_20*56)/(250*10^3))+T_enc_1_20*ms_to_sec*5.58*10^(-3);
E_tx_2_20_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_2_20*56)/(250*10^3))+T_enc_2_20*ms_to_sec*5.58*10^(-3);
E_tx_4_20_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_4_20*56)/(250*10^3))+T_enc_4_20*ms_to_sec*5.58*10^(-3);
E_tx_8_20_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_8_20*56)/(250*10^3))+T_enc_8_20*ms_to_sec*5.58*10^(-3);
E_tx_16_20_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_16_20*56)/(250*10^3))+T_enc_16_20*ms_to_sec*5.58*10^(-3);
E_tx_32_20_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_32_20*56)/(250*10^3))+T_enc_32_20*ms_to_sec*5.58*10^(-3);

E_rx_1_20_lt = (6.53*10^(-6))*(n_dec_1_20)+(33.8*10^(-3)).*((n_dec_1_20*56)/(250*10^3))+T_dec_1_20*ms_to_sec*5.58*10^(-3);
E_rx_2_20_lt = zeros(1,length(n_dec_2_20));
for i=1:length(n_dec_2_20)
    E_rx_2_20_lt(i) = (6.53*10^(-6))*(n_dec_2_20(i))+(33.8*10^(-3)).*((n_dec_2_20(i)*56)/(250*10^3))+T_dec_2_20(i)*ms_to_sec*5.58*10^(-3);
end
E_rx_4_20_lt = zeros(1,length(n_dec_4_20));
for i=1:length(n_dec_4_20)
    E_rx_4_20_lt(i) = (6.53*10^(-6))*(n_dec_4_20(i))+(33.8*10^(-3)).*((n_dec_4_20(i)*56)/(250*10^3))+T_dec_4_20(i)*ms_to_sec*5.58*10^(-3);
end
E_rx_8_20_lt = zeros(1,length(n_dec_8_20));
for i=1:length(n_dec_8_20)
    E_rx_8_20_lt(i) = (6.53*10^(-6))*(n_dec_8_20(i))+(33.8*10^(-3)).*((n_dec_8_20(i)*56)/(250*10^3))+T_dec_8_20(i)*ms_to_sec*5.58*10^(-3);
end
E_rx_16_20_lt = zeros(1,length(n_dec_16_20));
for i=1:length(n_dec_16_20)
    E_rx_16_20_lt(i) = (6.53*10^(-6))*(n_dec_16_20(i))+(33.8*10^(-3)).*((n_dec_16_20(i)*56)/(250*10^3))+T_dec_16_20(i)*ms_to_sec*5.58*10^(-3);
end
E_rx_32_20_lt = zeros(1,length(n_dec_32_20));
for i=1:length(n_dec_32_20)
    E_rx_32_20_lt(i) = (6.53*10^(-6))*(n_dec_32_20(i))+(33.8*10^(-3)).*((n_dec_32_20(i)*56)/(250*10^3))+T_dec_32_20(i)*ms_to_sec*5.58*10^(-3);
end

% 40% loss
E_tx_1_40_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_1_40*56)/(250*10^3))+T_enc_1_40*ms_to_sec*5.58*10^(-3);
E_tx_2_40_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_2_40*56)/(250*10^3))+T_enc_2_40*ms_to_sec*5.58*10^(-3);
E_tx_4_40_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_4_40*56)/(250*10^3))+T_enc_4_40*ms_to_sec*5.58*10^(-3);
E_tx_8_40_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_8_40*56)/(250*10^3))+T_enc_8_40*ms_to_sec*5.58*10^(-3);
E_tx_16_40_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_16_40*56)/(250*10^3))+T_enc_16_40*ms_to_sec*5.58*10^(-3);

E_rx_1_40_lt = (6.53*10^(-6))*(n_dec_1_40)+(33.8*10^(-3)).*((n_dec_1_40*56)/(250*10^3))+T_dec_1_40*ms_to_sec*5.58*10^(-3);
E_rx_2_40_lt = zeros(1,length(n_dec_2_40));
for i=1:length(n_dec_2_40)
    E_rx_2_40_lt(i) = (6.53*10^(-6))*(n_dec_2_40(i))+(33.8*10^(-3)).*((n_dec_2_40(i)*56)/(250*10^3))+T_dec_2_40(i)*ms_to_sec*5.58*10^(-3);
end
E_rx_4_40_lt = zeros(1,length(n_dec_4_40));
for i=1:length(n_dec_4_40)
    E_rx_4_40_lt(i) = (6.53*10^(-6))*(n_dec_4_40(i))+(33.8*10^(-3)).*((n_dec_4_40(i)*56)/(250*10^3))+T_dec_4_40(i)*ms_to_sec*5.58*10^(-3);
end
E_rx_8_40_lt = zeros(1,length(n_dec_8_40));
for i=1:length(n_dec_8_40)
    E_rx_8_40_lt(i) = (6.53*10^(-6))*(n_dec_8_40(i))+(33.8*10^(-3)).*((n_dec_8_40(i)*56)/(250*10^3))+T_dec_8_40(i)*ms_to_sec*5.58*10^(-3);
end
E_rx_16_40_lt = zeros(1,length(n_dec_16_40));
for i=1:length(n_dec_16_40)
    E_rx_16_40_lt(i) = (6.53*10^(-6))*(n_dec_16_40(i))+(33.8*10^(-3)).*((n_dec_16_40(i)*56)/(250*10^3))+T_dec_16_40(i)*ms_to_sec*5.58*10^(-3);
end

% 60% loss
E_tx_1_60_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_1_60*56)/(250*10^3))+T_enc_1_60*ms_to_sec*5.58*10^(-3);
E_tx_2_60_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_2_60*56)/(250*10^3))+T_enc_2_60*ms_to_sec*5.58*10^(-3);
E_tx_4_60_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_4_60*56)/(250*10^3))+T_enc_4_60*ms_to_sec*5.58*10^(-3);
E_tx_8_60_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_8_60*56)/(250*10^3))+T_enc_8_60*ms_to_sec*5.58*10^(-3);
E_tx_16_60_lt = 8.021*10^(-7)+31.32*10^(-3)*((n_enc_16_60*56)/(250*10^3))+T_enc_16_60*ms_to_sec*5.58*10^(-3);

E_rx_1_60_lt = (6.53*10^(-6))*(n_dec_1_60)+(33.8*10^(-3)).*((n_dec_1_60*56)/(250*10^3))+T_dec_1_60*ms_to_sec*5.58*10^(-3);
E_rx_2_60_lt = zeros(1,length(n_dec_2_60));
for i=1:length(n_dec_2_60)
    E_rx_2_60_lt(i) = (6.53*10^(-6))*(n_dec_2_60(i))+(33.8*10^(-3)).*((n_dec_2_60(i)*56)/(250*10^3))+T_dec_2_60(i)*ms_to_sec*5.58*10^(-3);
end
E_rx_4_60_lt = zeros(1,length(n_dec_4_60));
for i=1:length(n_dec_4_60)
    E_rx_4_60_lt(i) = (6.53*10^(-6))*(n_dec_4_60(i))+(33.8*10^(-3)).*((n_dec_4_60(i)*56)/(250*10^3))+T_dec_4_60(i)*ms_to_sec*5.58*10^(-3);
end
E_rx_8_60_lt = zeros(1,length(n_dec_8_60));
for i=1:length(n_dec_8_60)
    E_rx_8_60_lt(i) = (6.53*10^(-6))*(n_dec_8_60(i))+(33.8*10^(-3)).*((n_dec_8_60(i)*56)/(250*10^3))+T_dec_8_60(i)*ms_to_sec*5.58*10^(-3);
end
E_rx_16_60_lt = zeros(1,length(n_dec_16_60));
for i=1:length(n_dec_16_40)
    E_rx_16_60_lt(i) = (6.53*10^(-6))*(n_dec_16_60(i))+(33.8*10^(-3)).*((n_dec_16_60(i)*56)/(250*10^3))+T_dec_16_60(i)*ms_to_sec*5.58*10^(-3);
end

%% Energy per node in LT
number_of_nodes = [1, 2*ones(1, 2), 4*ones(1,4), 8*ones(1,8), 16*ones(1,16)];
node_energy_10 = [E_rx_1_10_lt, E_rx_2_10_lt, E_rx_4_10_lt, E_rx_8_10_lt, E_rx_16_10_lt];
gateway_energy_10 = [E_tx_1_10_lt, E_tx_2_10_lt, E_tx_4_10_lt, E_tx_8_10_lt, E_tx_16_10_lt];

node_energy_20 = [E_rx_1_20_lt, E_rx_2_20_lt, E_rx_4_20_lt, E_rx_8_20_lt, E_rx_16_20_lt];
gateway_energy_20 = [E_tx_1_20_lt, E_tx_2_20_lt, E_tx_4_20_lt, E_tx_8_20_lt, E_tx_16_20_lt];

figure(100)
plot(number_of_nodes, 1000.*node_energy_10, 'o', 'Color', 'red');
hold on
plot([1, 2, 4, 8, 16], 1000.*gateway_energy_10, 'x', 'Color', 'blue');
plot(number_of_nodes, 1000.*node_energy_20, 'x', 'Color', 'green');
plot([1, 2, 4, 8, 16], 1000.*gateway_energy_20, 'x', 'Color', 'black');
grid on
title('Energy spent decoder/encoder to recover 16 packets w. 10% packet loss with LT codes');
xlabel('Number of decoders');
ylabel('Energy [mJ]');
xlim([0 16])
ylim([0 1.2*max(1000.*node_energy_20)])
legend('Decoder', 'Encoder')
hold off

%% ARQ

% 1 node
n_1_10 = 19;
n_1_20 = 34;
n_1_40 = 32;
n_1_60 = 115;
% 2 nodes
n_2_10 = 21;
n_2_20 = 29;
n_2_40 = 64;
n_2_60 = 132;
% 4 nodes
n_4_10 = 29;
n_4_20 = 43;
n_4_40 = 64;
n_4_60 = 102;
% 8 nodes
n_8_10 = 26;
n_8_20 = 36;
n_8_40 = 93;
n_8_60 = 115;
% 16 nodes
n_16_10 = 32;
n_16_20 = 52;
n_16_40 = 101;
n_16_60 = 141;

% 32 nodes
n_32_20 = 60;

E_rx_1_10_ARQ = (6.53*10^(-6))*(n_1_10)+(33.8*10^(-3)).*((n_1_10*36)/(250*10^3));
E_rx_2_10_ARQ = (6.53*10^(-6))*(n_2_10)+(33.8*10^(-3)).*((n_2_10*36)/(250*10^3));
E_rx_4_10_ARQ = (6.53*10^(-6))*(n_4_10)+(33.8*10^(-3)).*((n_4_10*36)/(250*10^3));
E_rx_8_10_ARQ = (6.53*10^(-6))*(n_8_10)+(33.8*10^(-3)).*((n_8_10*36)/(250*10^3));
E_rx_16_10_ARQ = (6.53*10^(-6))*(n_16_10)+(33.8*10^(-3)).*((n_16_10*36)/(250*10^3));


E_rx_1_20_ARQ = (6.53*10^(-6))*(n_1_20)+(33.8*10^(-3)).*((n_1_20*36)/(250*10^3));
E_rx_2_20_ARQ = (6.53*10^(-6))*(n_2_20)+(33.8*10^(-3)).*((n_2_20*36)/(250*10^3));
E_rx_4_20_ARQ = (6.53*10^(-6))*(n_4_20)+(33.8*10^(-3)).*((n_4_20*36)/(250*10^3));
E_rx_8_20_ARQ = (6.53*10^(-6))*(n_8_20)+(33.8*10^(-3)).*((n_8_20*36)/(250*10^3));
E_rx_16_20_ARQ = (6.53*10^(-6))*(n_16_20)+(33.8*10^(-3)).*((n_16_20*36)/(250*10^3));
E_rx_32_20_ARQ = (6.53*10^(-6))*(n_32_20)+(33.8*10^(-3)).*((n_32_20*36)/(250*10^3));

E_rx_1_40_ARQ = (6.53*10^(-6))*(n_1_40)+(33.8*10^(-3)).*((n_1_40*36)/(250*10^3));
E_rx_2_40_ARQ = (6.53*10^(-6))*(n_2_40)+(33.8*10^(-3)).*((n_2_40*36)/(250*10^3));
E_rx_4_40_ARQ = (6.53*10^(-6))*(n_4_40)+(33.8*10^(-3)).*((n_4_40*36)/(250*10^3));
E_rx_8_40_ARQ = (6.53*10^(-6))*(n_8_40)+(33.8*10^(-3)).*((n_8_40*36)/(250*10^3));
E_rx_16_40_ARQ = (6.53*10^(-6))*(n_16_40)+(33.8*10^(-3)).*((n_16_40*36)/(250*10^3));

E_rx_1_60_ARQ = (6.53*10^(-6))*(n_1_60)+(33.8*10^(-3)).*((n_1_60*36)/(250*10^3));
E_rx_2_60_ARQ = (6.53*10^(-6))*(n_2_60)+(33.8*10^(-3)).*((n_2_60*36)/(250*10^3));
E_rx_4_60_ARQ = (6.53*10^(-6))*(n_4_60)+(33.8*10^(-3)).*((n_4_60*36)/(250*10^3));
E_rx_8_60_ARQ = (6.53*10^(-6))*(n_8_60)+(33.8*10^(-3)).*((n_8_60*36)/(250*10^3));
E_rx_16_60_ARQ = (6.53*10^(-6))*(n_16_60)+(33.8*10^(-3)).*((n_16_60*36)/(250*10^3));

E_tx_1_10_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_1_10*36)/(250*10^3));
E_tx_2_10_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_2_10*36)/(250*10^3));
E_tx_4_10_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_4_10*36)/(250*10^3));
E_tx_8_10_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_8_10*36)/(250*10^3));
E_tx_16_10_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_16_10*36)/(250*10^3));

E_tx_1_20_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_1_20*36)/(250*10^3));
E_tx_2_20_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_2_20*36)/(250*10^3));
E_tx_4_20_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_4_20*36)/(250*10^3));
E_tx_8_20_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_8_20*36)/(250*10^3));
E_tx_16_20_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_16_20*36)/(250*10^3));
E_tx_32_20_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_32_20*36)/(250*10^3));

E_tx_1_40_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_1_40*36)/(250*10^3));
E_tx_2_40_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_2_40*36)/(250*10^3));
E_tx_4_40_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_4_40*36)/(250*10^3));
E_tx_8_40_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_8_40*36)/(250*10^3));
E_tx_16_40_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_16_40*36)/(250*10^3));

E_tx_1_60_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_1_60*36)/(250*10^3));
E_tx_2_60_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_2_60*36)/(250*10^3));
E_tx_4_60_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_4_60*36)/(250*10^3));
E_tx_8_60_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_8_60*36)/(250*10^3));
E_tx_16_60_ARQ = 8.021*10^(-7)+31.32*10^(-3)*((n_16_60*36)/(250*10^3));

rx_energy_ARQ_10 = [E_rx_1_10_ARQ, E_rx_2_10_ARQ, E_rx_4_10_ARQ, E_rx_8_10_ARQ, E_rx_16_10_ARQ];
tx_energy_ARQ_10 = [E_tx_1_10_ARQ, E_tx_2_10_ARQ, E_tx_4_10_ARQ, E_tx_8_10_ARQ, E_tx_16_10_ARQ];

tx_energy_ARQ_20 = [E_tx_1_20_ARQ, E_tx_2_20_ARQ, E_tx_4_20_ARQ, E_tx_8_20_ARQ, E_tx_16_20_ARQ];
rx_energy_ARQ_20 = [E_rx_1_20_ARQ, E_rx_2_20_ARQ, E_rx_4_20_ARQ, E_rx_8_20_ARQ, E_rx_16_20_ARQ];

figure(101)
plot([1, 2, 4, 8, 16], 1000.*node_energy_ARQ_10, 'o', 'Color', 'red');
hold on
plot([1, 2, 4, 8, 16], 1000.*tx_energy_ARQ_10, 'x', 'Color', 'blue');
plot([1, 2, 4, 8, 16], 1000.*tx_energy_ARQ_20, 'x', 'Color', 'green');
plot([1, 2, 4, 8, 16], 1000.*rx_energy_ARQ_20, 'x', 'Color', 'black');
grid on
title('Energy spent recieve 16 packets w. 10% packet loss with ARQ');
xlabel('Number of decoders');
ylabel('Energy [mJ]');
xlim([0 16])
ylim([0 1.2*max(1000.*rx_energy_ARQ_20)])
legend('Receiver', 'Transmitter')
hold off

%% Average energy pr node

energy_avr_10_lt = [(E_tx_1_10_lt+E_rx_1_10_lt)/2, (sum(E_rx_2_10_lt)+E_tx_2_10_lt)/3,...
                    (sum(E_rx_4_10_lt)+E_tx_4_10_lt)/5, (sum(E_rx_8_10_lt)+E_tx_8_10_lt)/9,...
                    (sum(E_rx_16_10_lt)+E_tx_16_10_lt)/17];
energy_avr_20_lt = [(E_tx_1_20_lt+E_rx_1_20_lt)/2, (sum(E_rx_2_20_lt)+E_tx_2_20_lt)/3,...
                    (sum(E_rx_4_20_lt)+E_tx_4_20_lt)/5, (sum(E_rx_8_20_lt)+E_tx_8_20_lt)/9,...
                    (sum(E_rx_16_20_lt)+E_tx_16_20_lt)/17];
energy_avr_40_lt = [(E_tx_1_40_lt+E_rx_1_40_lt)/2, (sum(E_rx_2_40_lt)+E_tx_2_40_lt)/3,...
                    (sum(E_rx_4_40_lt)+E_tx_4_40_lt)/5, (sum(E_rx_8_40_lt)+E_tx_8_40_lt)/9,...
                    (sum(E_rx_16_40_lt)+E_tx_16_40_lt)/17];
energy_avr_60_lt = [(E_tx_1_60_lt+E_rx_1_60_lt)/2, (sum(E_rx_2_60_lt)+E_tx_2_60_lt)/3,...
                    (sum(E_rx_4_60_lt)+E_tx_4_60_lt)/5, (sum(E_rx_8_60_lt)+E_tx_8_60_lt)/9,...
                    (sum(E_rx_16_60_lt)+E_tx_16_60_lt)/17];

energy_avr_10_ARQ = [(E_tx_1_10_ARQ+E_rx_1_10_ARQ)/2, (E_tx_2_10_ARQ+2*E_rx_2_10_ARQ)/3,...
                     (E_tx_4_10_ARQ+4*E_rx_4_10_ARQ)/5,(E_tx_8_10_ARQ+8*E_rx_8_10_ARQ)/9,...
                     (E_tx_16_10_ARQ+16*E_rx_16_10_ARQ)/17];
energy_avr_20_ARQ = [(E_tx_1_20_ARQ+E_rx_1_20_ARQ)/2, (E_tx_2_20_ARQ+2*E_rx_2_20_ARQ)/3,...
                     (E_tx_4_20_ARQ+4*E_rx_4_20_ARQ)/5,(E_tx_8_20_ARQ+8*E_rx_8_20_ARQ)/9,...
                     (E_tx_16_20_ARQ+16*E_rx_16_20_ARQ)/17];
energy_avr_40_ARQ = [(E_tx_1_40_ARQ+E_rx_1_40_ARQ)/2, (E_tx_2_40_ARQ+2*E_rx_2_40_ARQ)/3,...
                     (E_tx_4_40_ARQ+4*E_rx_4_40_ARQ)/5,(E_tx_8_40_ARQ+8*E_rx_8_40_ARQ)/9,...
                     (E_tx_16_40_ARQ+16*E_rx_16_40_ARQ)/17];
energy_avr_60_ARQ = [(E_tx_1_60_ARQ+E_rx_1_60_ARQ)/2, (E_tx_2_60_ARQ+2*E_rx_2_60_ARQ)/3,...
                     (E_tx_4_60_ARQ+4*E_rx_4_60_ARQ)/5,(E_tx_8_60_ARQ+8*E_rx_8_60_ARQ)/9,...
                     (E_tx_16_60_ARQ+16*E_rx_16_60_ARQ)/17];

                 figure(100)
plot([1, 2, 4, 8, 16], 1000.*energy_avr_10_lt, '-o', 'Color','#00841a');
hold on
plot([1, 2, 4, 8, 16], 1000.*energy_avr_20_lt, '-o', 'Color', 'blue');
plot([1, 2, 4, 8, 16], 1000.*energy_avr_40_lt, '-o', 'Color', 'black');
plot([1, 2, 4, 8, 16], 1000.*energy_avr_60_lt, '-o', 'Color', 'red');
plot([1, 2, 4, 8, 16], 1000.*energy_avr_10_ARQ, '-.x', 'Color', '#00841a');
plot([1, 2, 4, 8, 16], 1000.*energy_avr_20_ARQ, '-.x', 'Color', 'blue');
plot([1, 2, 4, 8, 16], 1000.*energy_avr_40_ARQ, '-.x', 'Color', 'black');
plot([1, 2, 4, 8, 16], 1000.*energy_avr_60_ARQ, '-.x', 'Color', 'red');
grid on
title('Average energy spent per node to successfully transmit 16 packets');
xlabel('Number of receivers');
ylabel('Energy [mJ]');
xlim([1 16])
ylim([0 1.2*max(1000.*energy_avr_60_ARQ)])
legend('LT 10% loss', 'LT 20% loss', 'LT 40% loss', 'LT 60% loss', 'ARQ 10% loss', 'ARQ 20% loss', 'ARQ 40% loss', 'ARQ 60% loss')
hold off
%% Total energy pr system

% 10 % 
energy_total_10_lt = [E_tx_1_10_lt+E_rx_1_10_lt, E_tx_2_10_lt+sum(E_rx_2_10_lt),...
                      E_tx_4_10_lt+sum(E_rx_4_10_lt), E_tx_8_10_lt+sum(E_rx_8_10_lt),...
                      E_tx_16_10_lt+sum(E_rx_16_10_lt)];
energy_total_10_ARQ = [E_tx_1_10_ARQ+E_rx_1_10_ARQ, E_tx_2_10_ARQ+2*E_rx_2_10_ARQ,...
                       E_tx_4_10_ARQ+4*E_rx_4_10_ARQ, E_tx_8_10_ARQ+8*E_rx_8_10_ARQ,...
                       E_tx_16_10_ARQ+16*E_rx_16_10_ARQ];
% 20 %
energy_total_20_lt = [E_tx_1_20_lt+E_rx_1_20_lt, E_tx_2_20_lt+sum(E_rx_2_20_lt),...
                      E_tx_4_20_lt+sum(E_rx_4_20_lt), E_tx_8_20_lt+sum(E_rx_8_20_lt),...
                      E_tx_16_20_lt+sum(E_rx_16_20_lt)];
energy_total_20_ARQ = [E_tx_1_20_ARQ+E_rx_1_20_ARQ, E_tx_2_20_ARQ+2*E_rx_2_20_ARQ,...
                       E_tx_4_20_ARQ+4*E_rx_4_20_ARQ, E_tx_8_20_ARQ+8*E_rx_8_20_ARQ,...
                       E_tx_16_20_ARQ+16*E_rx_16_20_ARQ];
% 40 %
energy_total_40_lt = [E_tx_1_40_lt+E_rx_1_40_lt, E_tx_2_40_lt+sum(E_rx_2_40_lt),...
                      E_tx_4_40_lt+sum(E_rx_4_40_lt), E_tx_8_40_lt+sum(E_rx_8_40_lt),...
                      E_tx_16_40_lt+sum(E_rx_16_40_lt)];
energy_total_40_ARQ = [E_tx_1_40_ARQ+E_rx_1_40_ARQ, E_tx_2_40_ARQ+2*E_rx_2_40_ARQ,...
                       E_tx_4_40_ARQ+4*E_rx_4_40_ARQ, E_tx_8_40_ARQ+8*E_rx_8_40_ARQ,...
                       E_tx_16_40_ARQ+16*E_rx_16_40_ARQ];

% 60 %
energy_total_60_lt = [E_tx_1_60_lt+E_rx_1_60_lt, E_tx_2_60_lt+sum(E_rx_2_60_lt),...
                      E_tx_4_60_lt+sum(E_rx_4_60_lt), E_tx_8_60_lt+sum(E_rx_8_60_lt),...
                      E_tx_16_60_lt+sum(E_rx_16_60_lt)];
energy_total_60_ARQ = [E_tx_1_60_ARQ+E_rx_1_60_ARQ, E_tx_2_60_ARQ+2*E_rx_2_60_ARQ,...
                       E_tx_4_60_ARQ+4*E_rx_4_60_ARQ, E_tx_8_60_ARQ+8*E_rx_8_60_ARQ,...
                       E_tx_16_60_ARQ+16*E_rx_16_60_ARQ];

                   
figure(100)
plot([1, 2, 4, 8, 16], 1000.*energy_total_10_lt, '-o', 'Color','#00841a');
hold on
plot([1, 2, 4, 8, 16], 1000.*energy_total_20_lt, '-o', 'Color', 'blue');
plot([1, 2, 4, 8, 16], 1000.*energy_total_40_lt, '-o', 'Color', 'black');
plot([1, 2, 4, 8, 16], 1000.*energy_total_60_lt, '-o', 'Color', 'red');
plot([1, 2, 4, 8, 16], 1000.*energy_total_10_ARQ, '-.x', 'Color', '#00841a');
plot([1, 2, 4, 8, 16], 1000.*energy_total_20_ARQ, '-.x', 'Color', 'blue');
plot([1, 2, 4, 8, 16], 1000.*energy_total_40_ARQ, '-.x', 'Color', 'black');
plot([1, 2, 4, 8, 16], 1000.*energy_total_60_ARQ, '-.x', 'Color', 'red');
grid on
title('Total energy spent in system to successfully transmit 16 packets');
xlabel('Number of receivers');
ylabel('Energy [mJ]');
xlim([1 16])
ylim([0 1.2*max(1000.*energy_total_60_ARQ)])
legend('LT 10% loss', 'LT 20% loss', 'LT 40% loss', 'LT 60% loss', 'ARQ 10% loss', 'ARQ 20% loss', 'ARQ 40% loss', 'ARQ 60% loss')
hold off

%% Number of notes with 20%

energy_avr_20_lt_ext = [(E_tx_1_20_lt+E_rx_1_20_lt)/2, (sum(E_rx_2_20_lt)+E_tx_2_20_lt)/3,...
                        (sum(E_rx_4_20_lt)+E_tx_4_20_lt)/5, (sum(E_rx_8_20_lt)+E_tx_8_20_lt)/9,...
                        (sum(E_rx_16_20_lt)+E_tx_16_20_lt)/17, (sum(E_rx_32_20_lt)+E_tx_32_20_lt)/33];
energy_avr_20_ARQ_ext = [(E_tx_1_20_ARQ+E_rx_1_20_ARQ)/2, (E_tx_2_20_ARQ+2*E_rx_2_20_ARQ)/3,...
                         (E_tx_4_20_ARQ+4*E_rx_4_20_ARQ)/5,(E_tx_8_20_ARQ+8*E_rx_8_20_ARQ)/9,...
                         (E_tx_16_20_ARQ+16*E_rx_16_20_ARQ)/17, (E_tx_32_20_ARQ+32*E_rx_32_20_ARQ)/33];
                    
figure(100)
plot([1, 2, 4, 8, 16, 32], 1000.*energy_avr_20_lt_ext, '-o', 'Color', 'blue');
hold on
plot([1, 2, 4, 8, 16, 32], 1000.*energy_avr_20_ARQ_ext, '-.x', 'Color', 'red');
hold off
grid on
title('Average energy spent per node to successfully transmit 16 packets');
xlabel('Number of receivers');
ylabel('Energy [mJ]');
xlim([1 32])
ylim([min(1000.*energy_avr_20_ARQ_ext)-0.2*min(1000.*energy_avr_20_ARQ_ext) 1.2*max(1000.*energy_avr_20_ARQ_ext)])
legend('LT 20% loss', 'ARQ 20% loss')
hold off

%% Average decoding speed

decp = [n_dec_1_10, n_dec_2_10, n_dec_4_10, n_dec_8_10, n_dec_16_10,...
        n_dec_1_20, n_dec_2_20, n_dec_4_20, n_dec_8_20, n_dec_16_20,...
        n_dec_1_40, n_dec_2_40, n_dec_4_40, n_dec_8_40, n_dec_16_40,...
        n_dec_1_60, n_dec_2_60, n_dec_4_60, n_dec_8_60, n_dec_16_60,...
        n_dec_32_20];
    
decT = [T_dec_1_10, T_dec_2_10, T_dec_4_10, T_dec_8_10, T_dec_16_10,...
        T_dec_1_20, T_dec_2_20, T_dec_4_20, T_dec_8_20, T_dec_16_20,...
        T_dec_1_40, T_dec_2_40, T_dec_4_40, T_dec_8_40, T_dec_16_40,...
        T_dec_1_60, T_dec_2_60, T_dec_4_60, T_dec_8_60, T_dec_16_60,...
        T_dec_32_20];
 
figure(104);

subplot(2,1,1)
histogram(decp);
title('Histogram over number of code symbols to succesfully decode 16 packets');
xlabel('Number of code symbols [N]');
ylabel('Amount');
subplot(2,1,2)
histogram(decT);
title('Histogram over decoding time spent succesfully decode 16 packets');
xlabel('Decoding time [ms]');
ylabel('Amount');
figure(105);
histogram(decT);
title('Histogram over decoding time spent succesfully decode 16 packets');
xlabel('Decoding time [ms]');
ylabel('Amount');

decp_avr = sum(decp)/length(decp)
decT_avr = sum(decT)/length(decT)
timePrPacket_avr = decp_avr/decT_avr

