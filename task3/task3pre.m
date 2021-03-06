fid = fopen('./insurance.csv','r');
tline = fgetl(fid);
tline = fgetl(fid);  % filtering out the header
ages = [];
sexs = [];  % 1: male; 0: female
bmis = [];
children = [];
smokers = [];  % 0: non-smoker; 1: smoker
regions = [];  % 0: northeast, 1: northwest, 2: southeast, 3: southwest
charges = [];

% Distributions
sex_dist = zeros(1, 2, 'int8');
smoker_dist = zeros(1, 2, 'int8');
children_dist = zeros(1, 5, 'int8');
region_dist = zeros(1, 4, 'int8');

%{
sex_distribution = [male_num, female_num];
smoker_distribution = [smoker_num, non_smoker_num];
children_distribution = [children_1, children_2, children_3, children_4, children_5];
region_distribution = [northeast_num, northwest_num, southwest_num, southeast_num];
%}

while ischar(tline)
    disp(tline);
    line_data = split(tline, ",");
    ages(end + 1) = str2double(line_data(1)); 
    
    if (string(line_data(2)) == "male")
        sex_dist(1) = sex_dist(1) + 1;
    else
        sex_dist(2) = sex_dist(2) + 1;
    end
    
    if (string(line_data(5)) == "yes")
        smokers(end + 1) = 1;
        smoker_dist(1) = smoker_dist(1) + 1;
    else
        smokers(end + 1) = 0;
        smoker_dist(2) = smoker_dist(2) + 1;
    end

    switch str2double(line_data(4))
        case '1'
            children_dist(1) = children_dist(1) + 1;
        case '2'
            children_dist(2) = children_dist(2) + 1;
        case '3'
            children_dist(3) = children_dist(3) + 1;
        case '4'
            children_dist(4) = children_dist(4) + 1;
        case '5'
            children_dist(5) = children_dist(5) + 1;
    end

    switch string(line_data(6))
        case 'northeast'
            region_dist(1) = region_dist(1) + 1;
        case 'northwest'
            region_dist(2) = region_dist(2) + 1;
        case 'southwest'
            region_dist(3) = region_dist(3) + 1;
        case 'southeast'
            region_dist(4) = region_dist(4) + 1;
    end

    charges(end + 1) = str2double(line_data(7));

    tline = fgetl(fid);
end
fclose(fid);

age_train = [];
smoker_train = [];
charge_train = [];

for i = 1: 1038
    age_train(i) = ages(i);
    smoker_train(i) = smokers(i);
    charge_train(i) = charges(i);
end

age_test = [];
smoker_test = [];
charge_test = [];

for i = 1039: 1338
    age_test(i - 1038) = ages(i);
    smoker_test(i - 1038) = smokers(i);
    charge_test(i - 1038) = charges(i);
end

%X = [ones(1338,1), ages', children', bmi', sexs', smokers', regions'];
X = [ones(1038,1), age_train', smoker_train'];
Y = charge_train;
[b, bint] = regress(Y', X, 0.25); % b: coefficient; bint: coefficient bound 

error = [];
MSE = 0;

for i = 1:300
    % charges_pred = b(4) * smokers(i) + b(3) * ages(i) + b(2) * children(i) + b(1);
    % charges_pred = b(1) + b(2) * ages(i) + b(3) * children(i) + b(4) * bmi(i) + b(5) * sexs(i) + b(6) * smokers(i) + b(7) * region(i);
    charges_pred = b(1) + b(2) * age_test(i) + b(3) * smoker_test(i);
    error = [error, abs((charge_test(i) - charges_pred) / charge_test(i))];
    MSE = MSE + (charge_test(i) - charges_pred) ^ 2 / 300;
end

RMSE = sqrt(MSE);

figure(1);
testset = [1: 300];
plot(testset, error, 'r.');
title('Possibility of Error for Each Test Entry');
xlabel('Number of Tests');
ylabel('Possibility of Error');

figure(2);
boxplot(error, age_test);
title('Prediction Error Rate and Age');
xlabel('Age');
ylabel('Possibility of Error');

figure(3);
scatter3(ages, smokers, charges);
title('Relationship between Premium, Age, and Smoker Or Not');
%{
hold all;
x1_pred = 10: 1: 70;
x2_pred = 0: 1: 2;
[X1_pred, X2_pred] = meshgrid(x1_pred,x2_pred);
Y_pred = b(3) * X2_pred + b(2) * X1_pred + b(1);
mesh(Y_pred);
hold off
%}

figure(4);
boxplot(error, smoker_test);
title('Prediction Error Rate and Smoker Or Not');
ylabel('Possibility of Error');
set(gca, 'xticklabels', {'Smoker', 'Non-Smoker'});
%set(gca, 'xticklabels', {'Smoker', 'Non-Smoker'}, 'FontWeight', 'bold', 'Fontsize', 14);