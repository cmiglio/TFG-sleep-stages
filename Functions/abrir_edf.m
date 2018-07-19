function [EDF]=abrir_edf(FILENAME)


[EDF.FILE.FID,MESSAGE]=fopen(FILENAME,'r','ieee-le');   % Abrimos el fichero (lectura)
EDF.FileName = FILENAME;

PPos=min([max(find(FILENAME=='.')) length(FILENAME)+1]);
SPos=max([0 find(FILENAME==filesep)]);
EDF.FILE.Ext = FILENAME(PPos+1:length(FILENAME));  % extensi�n del fichero
EDF.FILE.Name = FILENAME(SPos+1:PPos-1); % nombre del fichero
if SPos==0,
   EDF.FILE.Path = pwd;  % path del fichero
else
	EDF.FILE.Path = FILENAME(1:SPos-1);  % path del fichero
end;

%CABECERA FIJA
[tmp,count]=fread(EDF.FILE.FID,184,'uchar');   % Lectura de los primeros 184 bytes
H1=setstr(tmp');
EDF.VERSION=H1(1:8);    % n�mero de versi�n (primeros 8 bytes de la cabecera est�tica)
EDF.PID = deblank(H1(9:88));  % identificaci�n local del paciente (80 bytes)
EDF.RID = deblank(H1(89:168));  % identificaci�n local de la grabaci�n (80 bytes)
tmp = str2num( H1(168 + [ 7  8])); 
EDF.T0(1) = tmp;  % a�o (fecha) de la grabaci�n 
tmp = str2num( H1(168 + [ 4  5]));
EDF.T0(2) = tmp;  % mes (fecha) de la grabaci�n
tmp = str2num( H1(168 + [ 1  2]));
EDF.T0(3) = tmp;  % d�a (fecha) de la grabaci�n
tmp = str2num( H1(168 + [ 9 10]));
EDF.T0(4) = tmp;  % hora (fecha) de la grabaci�n
tmp = str2num( H1(168 + [12 13]));
EDF.T0(5) = tmp;  % minuto (fecha) de la grabaci�n
tmp = str2num( H1(168 + [15 16]));
EDF.T0(6) = tmp;  % segundo (fecha) de la grabaci�n
H1(185:256)=setstr(fread(EDF.FILE.FID,256-184,'uchar')');
EDF.HeadLen = str2num(H1(185:192)); % n�mero de bytes en la cabecera (fija + variable)
EDF.reserved1=H1(193:236);  % 44 bytes reservados
EDF.NRec    = str2num(H1(237:244));  % n�mero de paquetes de datos
if isempty(EDF.NRec)
   EDF.NRec = -1;
end

EDF.Dur     = str2num(H1(245:252));  % duraci�n en segundos de cada paquete de datos
EDF.NS      = str2num(H1(253:256));  % n�mero de se�ales en cada paquete de datos

% CABECERA VARIABLE
fseek(EDF.FILE.FID,256,'bof');
EDF.Label      =  setstr(fread(EDF.FILE.FID,[16,EDF.NS],'uchar')'); % etiqueta de cada una de las se�ales (ej: EEG FpzCz o Body temp)
EDF.Transducer =  setstr(fread(EDF.FILE.FID,[80,EDF.NS],'uchar')'); % tipo de transductor usado en cada una de las se�ales (ej: AgCl electrode)
EDF.PhysDim    =  setstr(fread(EDF.FILE.FID,[ 8,EDF.NS],'uchar')'); % dimensi�n f�sica de cada se�al (ej: uV o degreeC)
EDF.PhysMin    =  setstr(fread(EDF.FILE.FID,[8,EDF.NS],'uchar')'); % m�nimo f�sico de cada se�al (ej: -500 o 34)
EDF.PhysMin=str2num(EDF.PhysMin);
EDF.PhysMax    =  setstr(fread(EDF.FILE.FID,[8,EDF.NS],'uchar')'); % m�ximo f�sico de cada se�al (ej: 500 o 40)
EDF.PhysMax=str2num(EDF.PhysMax);
EDF.DigMin    =  setstr(fread(EDF.FILE.FID,[8,EDF.NS],'uchar')'); % m�nimo digital de cada se�al (ej: -2048)
EDF.DigMin=str2num(EDF.DigMin);
EDF.DigMax    =  setstr(fread(EDF.FILE.FID,[8,EDF.NS],'uchar')'); % m�ximo digital de cada se�al (ej: 2047)
EDF.DigMax=str2num(EDF.DigMax);
EDF.PreFilt    =  setstr(fread(EDF.FILE.FID,[80,EDF.NS],'uchar')'); % prefiltrado realizado a cada se�al (ej: HP:0.1Hz LP:75Hz)
auxiliar  =  setstr(fread(EDF.FILE.FID,[8,EDF.NS],'uchar')'); % n�mero de muestras en cada paquete de datos para cada se�al
[fil,col]=size(auxiliar);
for i=1:fil,
    EDF.SPR(i)=str2num(auxiliar(i,:));
end
EDF.SPR=EDF.SPR';

% Otros par�metros referentes a la cabecera (calibraci�n, frecuencias de muestreo, etc..)
EDF.AS.MAXSPR=max(EDF.SPR); % n�mero de muestras m�ximo (de todas las se�ales) de un paquete de datos
if isempty(EDF.DigMax),
    EDF.DigMax=32767*ones(length(EDF.PhysMax),1);
end
if isempty(EDF.DigMin),
    EDF.DigMin=-32768*ones(length(EDF.PhysMin),1);
end
EDF.Cal = (EDF.PhysMax-EDF.PhysMin)./(EDF.DigMax-EDF.DigMin);
EDF.Off = EDF.PhysMin - EDF.Cal .* EDF.DigMin;
EDF.Calib=[EDF.Off';(diag(EDF.Cal))]; % matriz de calibraci�n
EDF.SampleRate = EDF.SPR / EDF.Dur;  % frecuencias de muestreo de cada se�al
EDF.AS.spb=sum(EDF.SPR); % n�mero de muestras en cada paquete de datos
EDF.AS.bpb=2*sum(EDF.SPR); % n�mero de bytes en cada paquete de datos (1 muestra=2 bytes) (son int16)

status = fseek(EDF.FILE.FID, 0, 'eof');
EDF.AS.endpos = ftell(EDF.FILE.FID); % n�mero de bytes total en el fichero (cabecera + paquetes de datos)
fseek(EDF.FILE.FID, EDF.HeadLen, 'bof'); %situamos el puntero en el fichero sobre el inicio del primer paquete de datos

if EDF.NRec == -1,  % tama�o de grabaci�n desconocido. Se calcula el n�mero de paquetes correcto
   EDF.NRec = floor((EDF.AS.endpos - EDF.HeadLen) / EDF.AS.bpb);
end
