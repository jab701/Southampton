k = 50.0;
timestep = 1E-6;
MaxTime = 100.0;
Mass = 1.0;

InitialPosition = 20.0;
Time = [0.0:timestep:MaxTime];

F = zeros(1,length(Time));
X = zeros(1,length(Time));
A = zeros(1,length(Time));
U = zeros(1,length(Time));

F(1) = -1.0 * k * InitialPosition;
A(1) = F(1)/Mass;
U(1) = 0.0;
X(1) = InitialPosition;
Last_PC = 0.0;
str = 1;
fprintf('\n');

for i = 2:length(Time),
    
    PC_Complete = (i/length(Time)) * 100.0;
    PC_Com_Floor = floor(PC_Complete);
    if (PC_Com_Floor ~= Last_PC)
        Last_PC = PC_Com_Floor;
        for j = 1: str,
            fprintf('\b');
        end
        str = fprintf('Percent Complete: %d%%', Last_PC);
    end
    
    A(i) = F(i-1)/Mass;
    U(i) = U(i-1) + A(i)*timestep;
    S = (U(i) * timestep) + (A(i)*timestep*timestep)/2.0;
        
    X(i) = X(i-1) + S;
    F(i) = -1.0 * k * X(i);
end
fprintf('\n');
fprintf('Execution Complete!\n');