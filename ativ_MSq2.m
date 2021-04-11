clc
close all
clear

%Input variáveis
prompt = {'Tensão do Motor: [V]','Potência do Motor: [HP]','Fator de Potência do Motor: ','Reatância Síncrona: [Ohm]','Perdas Mecânicas: [W]','Perdas no Núcleo: [W]','Potência inicial da carga: [HP]','Fator de Potência de Trabalho [FP]','Adiantado=1/Atrasado=2','Incremento de Fluxo: [%]','Valor Inicial da Corrente de Campo [A]','Valor Final da Corrente de Campo [A]','Incremento da Corrente de Campo [A]'};
dlgtitle = 'Input: Motor Síncrono';
dims = [1 50];
definput = {'208','45','0.8','2.5','1.5e3','1e3','15','0.85','2','10','3.5','6','0.1'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

% Motor em Delta

V_nom = str2num(answer{1});         % [V]
P_nom = str2num(answer{2});         % [HP]
FP_nom = str2num(answer{3});        % []
Xs = str2num(answer{4});            % [Ohms]
P_mec = str2num(answer{5});         % [W]
P_nuc = str2num(answer{6});         % [W]
P_ele = 0;                          % [W]
P_load = str2num(answer{7});        % [HP]
FP = str2num(answer{8});            % []
FP_type = str2num(answer{9});       % []
Inc_Fluxo = str2num(answer{10});    % [%]


% Pre-allocate Memory
Ea = zeros(1,5);
delta = zeros(1,5);
Ia = zeros(1,5);
FP = [FP, zeros(1,4)];

% Equations
P_out = P_load*746;                                                 % [W]
P_in = P_out + P_mec + P_nuc + P_ele;                               % [W]
Vphi = V_nom * exp(1i * 0);                                         % [V] (Delta)%FP inicial

if FP_type == 1
    Il = (P_in/(sqrt(3) * Vphi * FP(1))) * exp( 1i * acos(FP(1)));  % [A]
elseif FP_type == 2
    Il = (P_in/(sqrt(3) * Vphi * FP(1))) * exp( -1i * acos(FP(1))); % [A]
else
    warndlg('Entrada Inválida para o Tipo de Fator de Potência, digite 1 para atrasado ou 2 para adiantado'); 
    return
end

Ia(1) = Il/sqrt(3);                                                 % [A]
Ea(1) = Vphi - 1i * Xs * Ia(1);                                     % [V]
delta(1) = angle(Ea(1));                                            % [rad]

% Loop for incrementing Ea
for i = 2:length(Ea)
    
    Ea(i) = abs(Ea(1)) * (1 + Inc_Fluxo/100*(i-1));                  % [V] Incremento em 10%
    delta(i) = asin( (abs(Ea(i-1))/abs(Ea(i))) * sin(delta(i-1)));   % [rad] P_load = cte
    Ea(i) = abs(Ea(i)) * exp(1i * delta(i));
    Ia(i) = (Vphi - Ea(i))/(1i*Xs);
    FP(i) = cos(angle(Ia(i)));
    
end

figure
hold on
grid on

% Plot Vetor Vphi
quiver(0,0,real(Vphi),imag(Vphi),'AutoScale','off')
text(real(Vphi)+(real(Vphi)/100),imag(Vphi),'Vphi','Fontsize',9)
x = [real(Ea(1))-(real(Ea(3)-real(Ea(1))))/2:1: real(Ea(5))+(real(Ea(3)-real(Ea(1))))/2];
y = imag(Ea(1))*ones(length(x));
plot(x,y, 'k--')

% Plot Vetores Ea
for i=1:length(Ea)
    quiver(0,0,real(Ea(i)),imag(Ea(i)),'AutoScale','off');
    ID = 'Ea';
    ind = num2str(i);
    nome = strcat(ID,ind);
    text(real(Ea(i)),imag(Ea(i))+(imag(Ea(i)/30)),nome,'Fontsize',9);
end

% Plot Vetores jXsIa
for i=1:length(Ia)
    quiver(real(Ea(i)),imag(Ea(i)),real(1i*Xs*Ia(i)),imag(1i*Xs*Ia(i)),'AutoScale','off');
    ID = 'jXsIa';
    ind = num2str(i);
    nome = strcat(ID,ind);
    text(real(Ea(i))+(real(1i*Xs*Ia(i))/3),imag(Ea(i))+(imag(1i*Xs*Ia(i))/3),nome,'Fontsize',9);
end

% Plot Vetores Ia
for i=1:length(Ia)
    quiver(0,0,real(Ia(i)),imag(Ia(i)),'AutoScale','off');
    ID = 'Ia';
    ind = num2str(i);
    nome = strcat(ID,ind);
    text(real(Ia(i))+(real(Ia(i))/100),imag(Ia(i)+(imag(Ea(i)/100))),nome,'Fontsize',9);
end 
title('Diagrama Fasorial do Motor Síncrono Q2');


% Variação da Corrente de Campo
If = (str2num(answer{11}):str2num(answer{13}):str2num(answer{12}));
Ia = zeros(1,length(If)); 

% Cálculo da Corrente de Armadura com a variação da corrente de campo
for ii = 1:length(If)
    
Ea_2 = 45.5 * If(ii);
delta2 = asin(abs(Ea(1)) / abs(Ea_2) * sin(delta(1)));
Ea_2 = Ea_2 * (cos(delta2) + 1i * sin(delta2));
Ia(ii) = (Vphi - Ea_2) / (1i * Xs);
end

% Plot
figure
plot(If,abs(Ia),'Color','k','Linewidth',2.0);
xlabel('Corrente de campo (A)','Fontweight','Bold');
ylabel('Corrente de armadura (A)','Fontweight','Bold');
title ('Curva V de Motor Sincrono','Fontweight','Bold');
grid on;