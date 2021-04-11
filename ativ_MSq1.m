clc
close all
clear

%Input variáveis
prompt = {'Vphi: [V]','Potência: [HP]','Fator de Potência: ','Adiantado=1 /Atrasado=2','Reatância Síncrona: [Ohm]','Perdas Mecânicas: [kW]','Perdas no Núcleo: [kW]','Potência inicial da carga: [HP]','Incremento de carga: [HP]'};
dlgtitle = 'Input: Motor Síncrono';
dims = [1 50];
definput = {'208','45','0.8','1','2.5','1.5','1','15','5'};
answer = inputdlg(prompt,dlgtitle,dims,definput)

%Valores para cálculos iniciais
Pmec = str2num(answer{6})*1000;
Pnuc = str2num(answer{7})*1000;
Vt = str2num(answer{1});
FP(1) = str2num(answer{3});
temp(1) = str2num(answer{4});
thetaRad(1) = acos(FP(1));
%thetaGra = (thetaRad*180)/pi;
Xs = str2num(answer{5});
Vb = Vt;
Sb = str2num(answer{2})*746;
Ib = Sb/Vb;

%FP inicial
if temp(1) == 1
    IC(1) = 1;
    var{1} = 'adiantado';
elseif temp(1) == 2
    IC(1) = -1;
    var{1} = 'atrasado';
else
    warndlg('Entrada Inválida para o Tipo de Fator de Potência, digite 1 para adiantado ou 2 para atrasado'); 
    return
end

figure
hold on
%Vetor Vphi
Vtpu = Vt/Vb;
quiver(0,0,real(Vtpu),imag(Vtpu),'AutoScale','off')
text(real(Vtpu)+(real(Vtpu)/100),imag(Vtpu),'Vphi','Fontsize',9)

%Cálculo da Potência de entrada
%HPcarga = answer{1,1}(1,1);
HPcarga = str2num(answer{8})
Pout = HPcarga*746; %em W
Pin = Pout + Pmec + Pnuc;

%Cálculo de Ia, Il e Ea para carga inicial
Il = Pin/(sqrt(3)*Vt*FP);
Ia(1) = (Il/sqrt(3))*exp(IC(1)*i*thetaRad(1));
XsIa(1) = i*Xs*Ia(1);
Ea(1) = Vt - XsIa(1);

%Cálculo de Ia, Il e Ea para acrescimos de carga
incremento = str2num(answer{9})
for n=1:1:7
    HPcarga = str2num(answer{8})+incremento*n;
    Pout = HPcarga*746; %em W
    Pin = Pout + Pmec + Pnuc;
    
    %mudanças no FP
    sigma = asin((Xs*Pin)/(3*Vt*abs(Ea(n))));
    Ea(n+1) = abs(Ea(n))*exp(-i*sigma);
    Ia(n+1) = (Vt-Ea(n+1))/(i*Xs);
    XsIa(n+1) = i*Xs*Ia(n+1);
    thetaRad(n+1) = angle(Ia(n+1));
    FP(n+1) = cos(thetaRad(n+1));
    IC(n+1) = sin(thetaRad(n+1));
end

%cálculo de PU
Eapu = Ea/Vb;
XsIapu = XsIa/Vb;
Iapu = Ia/Ib;

%Circulo
th0 = linspace(0,-1*pi/3); 
r = abs(Eapu(1));
r = r(1);
c = [0 0]; 
x = c(1)+r*cos(th0); 
y = c(2)+r*sin(th0);
plot(x,y);

%Vetores Ea
for i=1:length(Ea)
    quiver(0,0,real(Eapu(i)),imag(Eapu(i)),'AutoScale','off');
    ID = 'Ea';
    ind = num2str(i);
    nome = strcat(ID,ind);
    text(real(Eapu(i))+(real(Eapu(i))/100),imag(Eapu(i))+(imag(Eapu(i)/100)),nome,'Fontsize',9);
end

%Vetores XsIa
for i=1:length(XsIapu)
    quiver(real(Eapu(i)),imag(Eapu(i)),real(XsIapu(i)),imag(XsIapu(i)),'AutoScale','off');
    ID = 'jXsIa';
    ind = num2str(i);
    nome = strcat(ID,ind);
    text(real(Eapu(i))+(real(XsIapu(i))/2),imag(Eapu(i))+(imag(XsIapu(i))/2),nome,'Fontsize',9);
end

%Vetores Ia
for i=1:length(Ia)
    quiver(0,0,real(Iapu(i)),imag(Iapu(i)),'AutoScale','off');
    ID = 'Ia';
    ind = num2str(i);
    nome = strcat(ID,ind);
    text(real(Iapu(i))+(real(Iapu(i))/100),imag(Iapu(i)+(imag(Eapu(i)/100))),nome,'Fontsize',9);
end 
hold off
title('Diagrama Fasorial do Motor Síncrono Q1');

%FP adiantado/atrasado
for i=1:length(IC)-1
    if IC(i+1) > 0
        var{i+1} = 'adiantado'
    elseif IC(i+1) < 0 
        var{i+1} = 'atrasado'
    else
        var{i+1} = 'undefined';
    end
end

%Tabela resumo
figure;
dat =  {abs(Ia(1)),abs(Ea(1)),abs(FP(1)),var{1};...
        abs(Ia(2)),abs(Ea(2)),abs(FP(2)),var{2};...   
        abs(Ia(3)),abs(Ea(3)),abs(FP(3)),var{3};...
        abs(Ia(4)),abs(Ea(4)),abs(FP(4)),var{4};...
        abs(Ia(5)),abs(Ea(5)),abs(FP(5)),var{5};...
        abs(Ia(6)),abs(Ea(6)),abs(FP(6)),var{6};...
        abs(Ia(7)),abs(Ea(7)),abs(FP(7)),var{7};...
        abs(Ia(8)),abs(Ea(8)),abs(FP(8)),var{8};};
columnname =   {'Ia','Ea','FP','Adian./Atras.'};
columnformat = {'numeric','numeric','numeric','char'}; 
uitable('Units','normalized','Position',...
            [0.05 0.05 0.755 0.87], 'Data', dat,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'RowName',[]);