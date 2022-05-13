%% Toolbox:
% Crear el robot con SerialLink y obtener la MTH:
%l = [14.5, 10.7, 10.7, 9]; % Longitudes eslabones profesor
l = [14.1, 10.5, 10.5, 9.7]; % Longitudes eslabones medidas
L(1) = Link('revolute','alpha',pi/2,'a',0,   'd',l(1),'offset',0,   'qlim',[-3*pi/4 3*pi/4]);
L(2) = Link('revolute','alpha',0,   'a',l(2),'d',0,   'offset',pi/2,'qlim',[-3*pi/4 3*pi/4]);
L(3) = Link('revolute','alpha',0,   'a',l(3),'d',0,   'offset',0,   'qlim',[-3*pi/4 3*pi/4]);
L(4) = Link('revolute','alpha',0,   'a',0,   'd',0,   'offset',0,   'qlim',[-3*pi/4 3*pi/4]);
PhantomX = SerialLink(L,'name','Px');
PhantomX.tool = [0 0 1 l(4); -1 0 0 0; 0 -1 0 0; 0 0 0 1];
ws = [-50 50];
PhantomX %#ok<NOPTS>
q0=[0,0,0,0];
MTH = PhantomX.fkine(q0); %MTH de la base a la herramienta.
MTH %#ok<NOPTS>
%% Graficar varias posiciones del robot:
figure(1)
%q0 = [0 0 0 0]; % Home
%q0 = [pi/3 pi/2 -pi/2 pi/4]; % Posicion 1
q0 = [-pi/4 pi/4 pi/4 pi/3]; % Posicion 2
PhantomX.plot(q0,'notiles','noname');
hold on
trplot(eye(4),'rgb','arrow','length',15,'frame','0')
axis([repmat(ws,1,2) 0 60])
view(-45,20)
hold off
%% Conexion con Matlab:
rosinit; %Conexion con nodo maestro. Correr solo una vez despues de iniciar el .launch apropiado.
%% Script para publicar a cada topico de controlador de junta:
motorSvcClient = rossvcclient('/dynamixel_workbench/dynamixel_command'); %Creación de cliente de pose y posición
motorCommandMsg = rosmessage(motorSvcClient); %Creación de mensaje
motorCommandMsg.AddrName = "Goal Position";
ID=1;   % Cambiar el valor de ID para seleccionar la junta a controlar.
%ID=2;
%ID=3;
%ID=4;
%ID=5;
motorCommandMsg.Id = ID;  % Asignar el Id del motor de la junta seleccionada.
q = [-45 45 45 60 0];  % Vector de angulos objetivo para cada motor en grados
motorCommandMsg.Value = round(mapfun(q(ID),-150,150,0,1023)); % Convierte los grados al valor de 10bits
if (motorCommandMsg.Value>=0 && motorCommandMsg.Value<=1023) % Verificar los limites y enviar el mensaje
    call(motorSvcClient,motorCommandMsg);
    pause(1);
end
%% Suscribirse al topico de la simulacion del Phantom X
poseSub = rossubscriber("/joint_states","sensor_msgs/JointState");
pause(1);
lastmsg = poseSub.LatestMessage;
lastmsg.Position   %Seleccionar e imprimir en conosla los valores de posicion angular del mensaje
%              Debe retornar 5 valores en radianes (eliminar lineas tras verificar!!!!)
%jointsmsg = receive(poseSub); %Forma alterna
%pause(1); 
%jointsmsg.Position

%% MATLAB + ROS + Toolbox:
q1=[0,0,0,0,0];
q2=[-20,20,-20,20,0];
q3=[-30,30,-30,30,0];
q4=[-90,15,-55,17,0];
q5=[-90,45,-55,45,10];
q=q1; %Cambiar la q para seleccionar cada posicion objetivo!

figure(1)  % Graficamos con ayuda del Toolbox la posicion objetivo que se desea obtener
PhantomX.plot(q(1:4),'notiles','noname');
hold on
trplot(eye(4),'rgb','arrow','length',15,'frame','0')
axis([repmat(ws,1,2) 0 60])
view(-45,20)
hold off

motorSvcClient = rossvcclient('/dynamixel_workbench/dynamixel_command'); %Creación de cliente de pose y posición
motorCommandMsg = rosmessage(motorSvcClient); %Creación del mensaje
motorCommandMsg.AddrName = "Goal Position"; 
for i=1:length(q) %Ciclo for para enviar los 5 mensajes de posicion a los motores de manera consecutiva.
    motorCommandMsg.Id = i;
    motorCommandMsg.Value = round(mapfun(q(i),-150,150,0,1023));
    if (motorCommandMsg.Value>=0 && motorCommandMsg.Value<=1023) % Verificar los limites y enviar el mensaje
        call(motorSvcClient,motorCommandMsg);
        pause(1);
    end
end
