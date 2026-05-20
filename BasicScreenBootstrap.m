%% Basic Bootstrap
% This script performs a basic bootstrap analysis on copulation duration
% screen data contained in a spreadsheet

%% Extract Screen Data

prompt = 'What is the spreadsheet name? (include extension)';
try
    % We are going to try an load the spreadsheet using importdata
    % because this will give us a structure that has the durations
    % stored as a double and the headers stored as a cell array
    spreadSheet = importdata(input(prompt,'s'));
catch
    % If there was a typo or something, we don't want to end this whole
    % process, we just want to give the user a chance to correct the
    % error and we can do that by sending them back to where we asked
    % if they have [another] spreadsheet to load
    warning('Spreadsheet not found');
end

% Set up a matrix where you will store all the duration data from all the
% spreadsheets you load
allData = [];
allData = [allData spreadSheet.data];
% Set up a cell array where you will store all the headers (aka genotype
% names)
genoTypes = {};
genoTypes = [genoTypes, spreadSheet.textdata];

disp('------All spreadsheets loaded------')

%% Prep data for analysis

% Decide if we are going to exclude any genotypes that don't have enough
% data points
% Ask the user if they want to exclude genotypes based on N
prompt = 'Do you want to set a minimum number of animals tested for a genotype to be included? Y/N';
str = input(prompt,'s');
% If they say nothing, then make it an automatic no
if isempty(str)
    str = 'N';
end
minNum = [];
if str == 'Y';
    prompt = 'What is the minimum n a genotype should have to be included? (6 recommended)';
    minNum = input(prompt);
    % count how many animals were tested for each genotype
    countGenos = sum(~isnan(allData),1);
    % countGenos>=minNum creates a logical array where everything with N or more
    % genotypes is a 1 and everything with less than N becomes a zero
    includeIndex = countGenos>=minNum;
    % taking the dot product of that and the allData matrix will convert the
    % entries in the columns with less than N to zeros
    filteredData = ((includeIndex).*allData);
else
    filteredData = allData;
end

% we then need to convert 0 entries into NaNs so they aren't counted as
% zero duration data points
filteredData(filteredData == 0) = NaN;

%% Create a simulation for bootstrapping

nDraws =[];
prompt = 'How many draws do you want to use for the bootstrap analysis';
nDraws = input(prompt);

% if the user doesn't specify how many draws, auto set to 100,000
if isempty(nDraws) == 1;
    nDraws = 100000;
end 

% Decide how many data points to be used for each 'genotype' in the
% simulation
if isempty(minNum) == 1;
    % automatically set to 15 if a minimum number of data points wasn't set
    % earlier
    minNum = 15;
end
simulatedData = zeros(minNum,nDraws);

% Create simulated data
% remove any gaps
filteredData = filteredData(~isnan(filteredData));
for i = 1:nDraws
    picks = randi(length(filteredData), minNum, nDraws); %pick 6 random integers from 1 to how ever many data points there are
    simulatedData(:,i) = [filteredData(picks(:,1))]; %use the picks to index into your data and turn it into real means
end
save('simulatedData.mat','simulatedData');

% Calculate the means of the satiated data
% calculate it (also called the sampling distribution of means)
meansVec = zeros(nDraws, 1);
for i = 1:nDraws
    meansVec(i,:) = mean(simulatedData(:,i));
end
% save it
save('simulatedMeans.mat','meansVec');

% plot the means
figName = 'SimulatedMeans';
histfit(meansVec(:,1))
title('Simulated Data')
xlabel('Mean  number of squares entered')
ylabel('Frequency')
saveas(gcf, figName, 'png')

%% Find the confidence intervals

ciBounds = NaN(2,2);

% 95% of the data falls between the 2.5th and the 97.5th percentiles
ciBounds(1,1) = prctile(meansVec(:,1),2.5);
ciBounds(2,1) = prctile(meansVec(:,1),97.5);

% 99% of the data falls between the 0.5th and 99.5th percentiles
ciBounds(1,2) = prctile(meansVec(:,1),0.5);
ciBounds(2,2) = prctile(meansVec(:,1),99.5);

%% Calculate a P-value

prompt = 'Do you want to calculate a P-value for a specific genotype?';
str = input(prompt,'s');
if str == 'Y'
    popMean = mean(meansVec);
    testMean = input('What is the mean of the genotype in question?' );
    diffMean = abs(popMean - testMean);
    pVal = (sum(meansVec < (popMean-diffMean)) + sum(meansVec > (popMean+diffMean)))/nDraws
end