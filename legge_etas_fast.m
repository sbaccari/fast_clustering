clear all
xcell=1;
num_thr=1;
pthmin=1E-18;
pthmax=1E15;

pcat=4;
qmin=3;
nbg=0;


ipmin=fix(log(pthmin)/0.05);
ipmax=fix(log(pthmax)/0.05);

switch pcat
    case 2
        name='p2.dat';
    case 3
        name='p3.dat';
    otherwise
        name='p4.dat';
end


ijt=0; % Number of events in Σο since t0
ijk=0; % Number of events in Σ since t_in
data = importfile(name,1,inf);

for i=1:size(data,1)
    tt=data.tt(i);
    qq=data.qq(i);
    ltt=data.ltt(i);
    lnn=data.lnn(i);
    j1=data.j1(i);
    %X = [' tt:',num2str(tt),' qq:',num2str(qq),' ltt:',num2str(ltt),' lnn:',num2str(lnn),' j1:',num2str(j1) ];
    %disp(X)
    if (qq>=qmin)
        if(j1==0)
            nbg=nbg+1;
        end
        ijt=ijt+1;
        disp(ijt);
        t2(ijt)=tt/(3600*24); % time unit into days
        lt2(ijt)=ltt;%!+(-2*0.001)*rand()+0.001
        ln2(ijt)=lnn;%!+(-2*0.001)*rand()+0.001
        q2(ijt)=qq;
        ijk=ijk+1;
        t(ijk)=tt/(3600*24) ;
        lt(ijk)=ltt;
        ln(ijk)=lnn;
        q(ijk)=qq;
    end
end
tic
%clear('data')
%clear('tt','qq','ltt','lnn','j1')

npt=i-1;

disp(['Number of events in Σο ' num2str(ijt)]);
disp(['Total number of events in Σ :' num2str(ijk)]);
disp(nbg);

OFFSET=5000;
nlink(OFFSET+1-ipmin+ipmax)=int32(0); %! numero connessioni
kr(OFFSET+1-ipmin+ipmax)=int32(0); %! numero inizio della radice
nlink=int32(zeros(size(nlink))); %! numero connessioni
kr=int32(zeros(size(nlink))); %! numero inizio della radice

for ip=ipmin:ipmax
    nlink(ip+OFFSET)=int32(0); %! numero connessioni
    kr(ip+OFFSET)=int32(0)	 ; %! numero inizio della radice
end

ipmaxt=ipmax;
for i=2:ijk
    ixxx=lt(i);
    iyyy=ln(i);
    ipmaxt=ipmin;
    for indicej=i-1:-1:1
        %do j=i-1,1,-1
        l1=metric(ixxx,iyyy,t(i),lt(indicej),ln(indicej),t(indicej),q(indicej));
        %%metric(l1,ixxx,iyyy,t(i),lt(j),ln(j),t(j),q(j))
        %disp(l1)
        ipf=max(ipmin,fix(log(l1)/0.05));
        %max(ipmin,int(log(l1)/0.05))
        ipmaxt=max(ipf,ipmaxt);
        for ip=ipmin:ipf
            nlink(ip+OFFSET)=nlink(ip+OFFSET)+1;
        end
    end
    parfor ip=ipmaxt+1:ipmax
        kr(ip+OFFSET)=kr(ip+OFFSET)+1;
    end
end


max(kr)
%histogram(kr)
num_x=25;
num_y=25;
%write(num_x,73)int(qmin*10)
%write(num_y,72)pcat!int(a(2)*100)
%write(num_z,73)int(a(7)*100)



nome1=['1f_zmxy_qmin' num2str(num_x) '_cat_' num2str(num_y) '.dat'];
fileID = fopen(nome1,'w');
toc

for ip=ipmax:-1:ipmin+10
    if(kr(ip+OFFSET)==1)
        break
    end
    if(nlink(ip-10+OFFSET)>nlink(ip+OFFSET))
        zmexp=((double(kr(ip+OFFSET))-double(kr(ip-10+OFFSET)))/(double(nlink(ip-10+OFFSET))-double(nlink(ip+OFFSET))));
        %if (abs(zmexp)>1e-6)
        %    disp(zmexp);
        %end
        %zmexp=(kr(ip)-kr(ip-10))*1d0/(nlink(ip-10)-nlink(ip))
        %%fprintf(fileID,'%12d %fL %12d\n',kr(ip+OFFSET),zmexp,nlink(ip+OFFSET));
    end
end

fclose(fileID);



function met=metric(x1,y1,t1,x3,y3,t3,q3)
d0=1E-15;
%pp=1.2;%1.08            !omori exponent
%alpha=1.0;%0.9

dr=sqrt((x1-x3)^2+(y1-y3)^2);
dt=(t1-t3)*3600;
% cc=0.024*3600*24 !0.01
%disp(dr)
%disp(dt)
%dm=0.006*exp(1.958*(q3-2))*1E-4
% fdr=dr*(dr/dm+1)**(-3)*(dm**(-2))
met=(1/(dt*(dr^2)*10^(-q3)+d0));
end


function data = importfile(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as a matrix.
%   DATA = IMPORTFILE(FILENAME)
%   Reads data from text file FILENAME for the default selection.
%
%   DATA = IMPORTFILE(FILENAME, STARTROW, ENDROW)
%   Reads data from rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   data = importfile('p4.dat', 1, 31045);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2022/02/17 12:18:50

%% Initialize variables.
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Format for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%21f%18f%17f%17f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this code. If an error occurs for a different file, try regenerating the code from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post processing code is included. To generate code which works for unimportable data, select unimportable cells in a file and regenerate the script.

%% Create output variable
data = table(dataArray{1:end-1}, 'VariableNames', {'tt','qq','ltt','lnn','j1'});


end

