clc
close all
clear

%Input variáveis
prompt = {'Vphi: [V]','Eficiência: [%]','Fator de Potência: ','Conexão: 1-estrela, 2-delta','Velocidade: [rpm]','Frequência de entrada: [Hz]','Potência de saída: [W]','Perdas rotacionais: [W]'};
dlgtitle = 'Input: Motor Síncrono';
dims = [1 50];
definput = {'380','80','0.92','1','2800','50','3000','120'};
answer = inputdlg(prompt,dlgtitle,dims,definput)

%Valores para cálculos iniciais
Vt = str2num(answer{1});
rendimento = (str2num(answer{2}))/100;
FP = str2num(answer{3});
conexao = str2num(answer{4});
n_m = str2num(answer{5});
f_se = str2num(answer{6});
Pout = str2num(answer{7});
Prot = str2num(answer{8});

%letra a)
Ptemp = (120*f_se)/n_m;
P = floor(Ptemp);                  % <=========
n_sinc = (120*f_se)/P;            
S = 1 - (n_m/n_sinc);              % <=========

%letra b)
Pin = Pout/rendimento;             % <=========
if conexao == 1
    Il = Pin/(sqrt(3)*Vt*FP);      % <=========
elseif conexao == 2
    Il = (Pin/(3*Vt*FP))*sqrt(3);
else
    warndlg('Entrada Inválida para o Tipo de conexão, digite 1 para estrela ou 2 para delta'); 
    return
end

%letra c)
Pconv = Pout + Prot;               % <=========
Pef = Pout/(1-S);                  % <=========

%letra d)
w_m = (n_m*2*pi)/60;
Tcarga = Pout/w_m;                 % <=========

%letra e)
Tind = Pconv/w_m;                  % <=========

%Tabela resumo
figure;
dat =  {'Pólos','Pot. entrada','Pot. convertida','Torque no eixo','Torque eletromagnético';...
        P,Pin,Pconv,Tcarga,Tind;...
        'Escorregamento','Corrente de entrada','Pot. eletromagnética','-','-';...
        S,Il,Pef,'-','-';};
columnname =   {'a)','b)','c)','d)','e)'};
columnformat = {'numeric','numeric','numeric','numeric','numeric'}; 
uitable('Units','normalized','Position',...
            [0.05 0.05 0.755 0.87], 'Data', dat,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'RowName',[]);