theta=linspace(0,2*pi,101);
x=CC(2)+r*cos(theta);
y=CC(1)+r*sin(theta);

plot(x,y,'r-','linewidth',2.5);
% ABC=[A;B;C];
% plot(ABC(:,2),ABC(:,1),'b.','markersize',20)
plot(CC(2),CC(1),'r.','markersize',10)
axis equal
