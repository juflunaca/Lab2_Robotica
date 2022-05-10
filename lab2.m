%%
%rosinit; %Conexion con nodo maestro. No es necesaria, iniciar el launch en
%su lugar.
%%
%l = [14.5, 10.7, 10.7, 9]; % Longitudes eslabones profesor
l = [8.05, 10.5, 10.5, 9.7]; % Longitudes eslabones medidas
% Definicion del robot RTB
L(1) = Link('revolute','alpha',pi/2,'a',0,   'd',l(1),'offset',0,   'qlim',[-3*pi/4 3*pi/4]);
L(2) = Link('revolute','alpha',0,   'a',l(2),'d',0,   'offset',pi/2,'qlim',[-3*pi/4 3*pi/4]);
L(3) = Link('revolute','alpha',0,   'a',l(3),'d',0,   'offset',0,   'qlim',[-3*pi/4 3*pi/4]);
L(4) = Link('revolute','alpha',0,   'a',0,   'd',0,   'offset',0,   'qlim',[-3*pi/4 3*pi/4]);
PhantomX = SerialLink(L,'name','Px');
% roty(pi/2)*rotz(-pi/2)
PhantomX.tool = [0 0 1 l(4); -1 0 0 0; 0 -1 0 0; 0 0 0 1];
ws = [-50 50];
% Graficar robot
PhantomX.plot([0 0 0 0],'notiles','noname');
hold on
trplot(eye(4),'rgb','arrow','length',15,'frame','0')
axis([repmat(ws,1,2) 0 60])
%%
motorSvcClient = rossvcclient('/dynamixel_workbench/dynamixel_command'); %Creación de cliente de pose y posición
motorCommandMsg = rosmessage(motorSvcClient); %Creación de mensaje
%%
q=[60, -45, -45, 30];
q_1=[0,0,0,0,0];
q_2=[-20,20,-20,20,0];
q_3=[-30,30,-30,30,0];
q_4=[-90,15,-55,17,0];
q_5=[-90,45,-55,45,10];

motorCommandMsg.AddrName = "Goal Position";
for i=1:length(q)  %Cambiar la q para cada posicion
    motorCommandMsg.Id = i;
    motorCommandMsg.Value = round(mapfun(q(i),-150,150,0,1023));
    call(motorSvcClient,motorCommandMsg) ;
    pause(1);
end

%% Suscribirse al topico de la simulacion del Phantom X
poseSub = rossubscriber("/dynamixel_workbench/dynamixel_command","dynamixel_msgs/JointState");
lastmsg = poseSub.LatestMessage;

