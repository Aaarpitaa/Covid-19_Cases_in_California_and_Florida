/*Group 7 Final Code Review Assignment - How COVID cases vary over time in CA vs FL in response to state level
COVID mitigation policies**/
/**imported vaccine, covid, stay at home, mask, and population data**/

PROC IMPORT OUT= WORK.vaccine 
            DATAFILE= "C:\Users\cckra\Documents\Drexel\Classes\Fall 2022\BST 555\Vaccine Data_dedup.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

PROC IMPORT OUT= WORK.cases 
            DATAFILE= "C:\Users\cckra\Documents\Drexel\Classes\Fall 2022\BST 555\COVID Data_dedup.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

PROC IMPORT OUT= WORK.pop 
            DATAFILE= "C:\Users\cckra\Documents\Drexel\Classes\Fall 2022\BST 555\Population Data.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

PROC IMPORT OUT= WORK.sah 
            DATAFILE= "C:\Users\cckra\Documents\Drexel\Classes\Fall 2022\BST 555\Stay At Home Data.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

PROC IMPORT OUT= MASK 
            DATAFILE= "C:\Users\cckra\Documents\Drexel\Classes\Fall 2022\BST 555\Face Mask Mandate Data.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

/**sort the datasets on state so it can then be merged on state.**/

proc sort data=pop;
by state;
run;

proc sort data=cases;
by state; 
run;

proc sort data=sah;
by state;
run;

proc sort data=mask;
by state;
run;


/*Merge datasets cases with population, SAH mandate and mask mandate datasets. Merged on state variable*/

data covidvaxx;
merge cases (in=A) pop sah mask;
by state;
if A then output;
run;
 
/*Sorted the newly created covidvaxx dataset and the vaccine dataset by state and date so they can then be merged in the next step*/

proc sort data=covidvaxx; by STATE DATE; run;
proc sort data=vaccine; by STATE DATE; run;

/*Merge datasets COVIDVAXX with VACCINE on variables state and date to create dataset covidvaxx2*/

data covidvaxx2;
	merge covidvaxx (IN=A) VACCINE; by STATE DATE;
	if A then output;
run;


/*run a proc print to check our code and make sure covidvaxx2 was created properly*/

proc print data=covidvaxx2 (obs=50) noobs;
run;

/**sort covidvaxx2 by state and date**/


proc sort data=covidvaxx2; 
by state date;
run; 

/**run another proc print to ensure our data sorted properly. Checking the CA values**/

proc print data=covidvaxx2 (obs=50) noobs;
where date ge mdy (1, 30, 2021) and state="CA";
run;

/*Create a new dataset COVIDVAXX3 in which the 7-day average of COVID cases is calculated. This variable is called Avgcases. Use retain and if statements to have COVIDVAXX3 include
25th and 75th percentile of those vaccinated and the dates when the mask mandate started and ended. Output will be covidvaxx3 dataset with formats applied.*/
data covidvaxx3
      Avgcases;
set covidvaxx2;
by state date;
retain VAXX_25 VAXX_75 PCT_VAXX MASK_BEGIN MASK_END; 
CASE7=(((new_case+lag1(new_case)+lag2(new_case)+lag3(new_case)+lag4(new_case)+lag5(new_case)+lag6(new_case))/7)/population)*100000;
if first.STATE then PCT_VAXX=0;
		else if SERIES_COMPLETE ne . then PCT_VAXX=SERIES_COMPLETE;
if first.STATE then VAXX_25=.;
	if VAXX_25 = . and Series_Complete ge 25 then VAXX_25=date;
if first.STATE then VAXX_75=.;
	if VAXX_75 = . and Series_Complete ge 75 then VAXX_75=date;
format VAXX_25 VAXX_75 MMDDYY10. POPULATION COMMA10.;
	label CASE7="7 Day Average Of New Cases Per 100,000 Population";
	label PCT_VAXX="Percent Vaccinated";
	label VAXX_25="Date 25% Vaccinated";
	label VAXX_75="Date 75% Vaccinated";
	label MASK_BEGIN="Mask Mandate Begins"; 
	label MASK_END="Mask Mandate Ends";
if last.STATE then output Avgcases;
    if state ne "" then output covidvaxx3;
run;

/*run a proc print to check our code with state=CA and date >= March 1, 2021 (so we can check vaccine rates also)*/
proc print data=covidvaxx3(obs=50)noobs;
where state="CA" and date ge mdy(3,1,2021);
run;

/**ran other proc prints to check our code**/

proc print data=covidvaxx3 (obs=50) noobs;run;
proc print data=Avgcases(obs=50)noobs;run;

/*Sort covidvaxx3 dataset by state and avgcases by state so they can be merged in the next step*/
proc sort data=covidvaxx3; by STATE; run;
proc sort data=Avgcases; by STATE; run;

/**merge covixvaxx3 with avgcases on state to create dataset called project; keep formatting from covidvaxx3 in project dataset. **/
data project;
merge covidvaxx3  Avgcases; by STATE;
if date < MDY(1,1,2020) then delete; 
	label PCT_VAXX="Percent Vaccinated";
	label VAXX_25="Date 25% Vaccinated";
	label VAXX_75="Date 75% Vaccinated";
	label SAH_BEGIN="Stay-at-home Order Begins";
	label SAH_END="Stay-at-home Order Ends";
	label MASK_BEGIN="Mask Mandate Begins";
	label MASK_END="Mask Mandate Ends";
run;

/**sort project dataset by state**/

proc sort data=project; by state date;run;

/**run a proc print of project dataset to check everything merged and sorted correctly**/
proc print data=project(obs=300)noobs;
where state="CA" and date ge mdy(5,1,2021);
run;

/*Plotted scatter plots for California, where x=date and y=7 day case avg. We did this to check our work and visualize the data before plotting LOESS curves later on. Separated by year 1 and year
2 of the pandemic.*/

/*scatter plot graph for Time= January 2020 to January 2021*/
proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in California Y20-21";
	where state="CA" and date ge MDY(1,1,2020) AND date le MDY(1,31,2021);
	scatter x=date y=CASE7;
run;

/*scatter plot graph for Time= January 2021 to January 2022*/
proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in California Y21-22";
	where state="CA" and date ge MDY(1,1,2021) AND date le MDY(1,31,2022);
	scatter x=date y=CASE7;
run;


/*Plotting LOESS Curves for California, where x=date and y=7 day case avg. Plotted these curves without reference lines/legend/other visualizations so we could see the curve of 
just the average covid cases in CA (separated by year 1 and year 2)*/

/*graph for Time= January 2020 to January 2021*/

proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in California Y20-21";
	where state="CA" and date ge MDY(1,1,2020) AND date le MDY(1,31,2021);
	loess x=date y=CASE7/nomarkers;
run;

/*graph for Time= January 2021 to January 2022*/

proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in California Y21-22";
	where state="CA" and date ge MDY(1,1,2021) AND date le MDY(1,31,2022);
	loess x=date y=CASE7/nomarkers;
run;


/*Repeated the same steps as above for Florida. Ran scatter plots first to visualize data (separated by year 1 and year 2) and then ran LOESS curves but without any special features 
or added visualization (separated by year 1 and year 2 for Florida)*/
proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in Florida Y20-21";
	where state="FL" and date ge MDY(1,1,2020) AND date le MDY(1,31,2021);
	scatter x=date y=CASE7;
run;

proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in Florida Y21-22";
	where state="FL" and date ge MDY(1,1,2021) AND date le MDY(1,31,2022);
	scatter x=date y=CASE7;
run;

proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in Florida Y20-21";
	where state="FL" and date ge MDY(1,1,2020) AND date le MDY(1,31,2021);
	loess x=date y=CASE7/nomarkers;
run;

proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in Florida Y21-22";
	where state="FL" and date ge MDY(1,1,2021) AND date le MDY(1,31,2022);
	loess x=date y=CASE7/nomarkers;
run;

/*LOESS Curves for both CA and FL, where reference lines are 25% and 75% Vaccinated +
SAH Mandate begins and ends. In these curves, we separated the two states for year 1 of the pandemic and year 2 of the pandemic. Added visualizations such as colors for the LOESS
curves, colors for reference lines, legend, axis labels, and title.*/

/*Graphs for CA and FL for the time duration: Jan 1, 2020 to Jan 31, 2021*/
proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in California Y20-21";
	where state="CA" and date ge MDY(1,1,2020) and date le MDY(1,31,2021);
	loess x=date y=CASE7/nomarkers lineattrs=(color=blue) legendlabel="Cases";
	yaxis label="7-Day Average Cases per 100,000" values=(0 to 500 by 50);
refline VAXX_25/ axis=x lineattrs=(thickness=1 color=green pattern=Dash) legendlabel="25% of Population Vaccinated" NAME="VAX25";
	refline VAXX_75/ axis=x lineattrs=(thickness=1 color=red pattern=Dash)legendlabel="75% of Population Vaccinated" NAME="VAX75";
refline SAH_begin/ axis=x lineattrs=(thickness=0.5 color=black pattern=ShortDash) legendlabel="Stay-at-Home Mandate Begins" NAME="SAHBEGIN";
	refline SAH_end/ axis=x lineattrs=(thickness=0.5 color=grey pattern=ShortDash)legendlabel="Stay-at-Home Ends" NAME="SAHEND";
keylegend "VAX25" "VAX75" "SAHBEGIN" "SAHEND";
run;

proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in Florida Y20-21";
	where state="FL" and date ge MDY(1,1,2020) and date le MDY(1,31,2021);
	loess x=date y=CASE7/nomarkers lineattrs=(color=yellow) legendlabel="Cases";
	yaxis label="7-Day Average Cases per 100,000" values=(0 to 500 by 50);
refline VAXX_25/ axis=x lineattrs=(thickness=1 color=green pattern=Dash) legendlabel="25% of Population Vaccinated" NAME="VAX25";
	refline VAXX_75/ axis=x lineattrs=(thickness=1 color=red pattern=Dash)legendlabel="75% of Population Vaccinated" NAME="VAX75";
refline SAH_begin/ axis=x lineattrs=(thickness=0.5 color=black pattern=ShortDash) legendlabel="Stay-at-Home Mandate Begins" NAME="SAHBEGIN";
	refline SAH_end/ axis=x lineattrs=(thickness=0.5 color=grey pattern=ShortDash)legendlabel="Stay-at-Home Ends" NAME="SAHEND";
keylegend "VAX25" "VAX75" "SAHBEGIN" "SAHEND";
run;

/*Graphs for CA and FL for the time duration: Jan 1,2021 to Jan 31, 2022*/
proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in California Y21-22";
	where state="CA" and date ge MDY(1,1,2021) and date le MDY(1,31,2022);
	loess x=date y=CASE7/nomarkers lineattrs=(color=blue) legendlabel="Cases";
	yaxis label="7-Day Average Cases per 100,000" values=(0 to 500 by 50);
		refline VAXX_25/ axis=x lineattrs=(thickness=1 color=green pattern=Dash) legendlabel="25% of Population Vaccinated" NAME="VAX25";
	refline VAXX_75/ axis=x lineattrs=(thickness=1 color=red pattern=Dash)legendlabel="75% of Population Vaccinated" NAME="VAX75";
refline SAH_begin/ axis=x lineattrs=(thickness=0.5 color=black pattern=ShortDash) legendlabel="Stay-at-Home Mandate Begins" NAME="SAHBEGIN";
	refline SAH_end/ axis=x lineattrs=(thickness=0.5 color=grey pattern=ShortDash)legendlabel="Stay-at-Home Ends" NAME="SAHEND";
keylegend "VAX25" "VAX75" "SAHBEGIN" "SAHEND";
run;

proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in Florida Y21-22";
	where state="FL" and date ge MDY(1,1,2021) and date le MDY(1,31,2022);
	loess x=date y=CASE7/nomarkers lineattrs=(color=yellow) legendlabel="Cases";
	yaxis label="7-Day Average Cases per 100,000" values=(0 to 500 by 50);
		refline VAXX_25/ axis=x lineattrs=(thickness=1 color=green pattern=Dash) legendlabel="25% of Population Vaccinated" NAME="VAX25";
	refline VAXX_75/ axis=x lineattrs=(thickness=1 color=red pattern=Dash)legendlabel="75% of Population Vaccinated" NAME="VAX75";
refline SAH_begin/ axis=x lineattrs=(thickness=0.5 color=black pattern=ShortDash) legendlabel="Stay-at-Home Mandate Begins" NAME="SAHBEGIN";
	refline SAH_end/ axis=x lineattrs=(thickness=0.5 color=grey pattern=ShortDash)legendlabel="Stay-at-Home Ends" NAME="SAHEND";
keylegend "VAX25" "VAX75" "SAHBEGIN" "SAHEND";
run;


/*NOTE: After plotting the above graphs, we decided we wanted to add reference lines for mask mandates because they 
pertain to our research question. We also decided to plot the graphs for CA and FL each with the entire 2-year time period 
on one graph because we felt it was easier to see all of the reference lines that way. This makes it easier to compare
the two states. These are our final LOESS curves which will be discussed in our write-up.*/

/*LOESS Curves for both CA and FL, where reference lines are 25% and 75% Vaccinated +
SAH Mandate begins and ends + MASK Mandate Begins and ends */

/*Graphs for CA and FL for the time duration: Jan 1, 2020 to Jan 31, 2022*/
ods graphics / width=8in height=4in;
ods layout gridded columns=2 advance=table;

proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in California Y20-22";
	where state="CA" and date ge MDY(1,1,2020) and date le MDY(1,31,2022);
	loess x=date y=CASE7/nomarkers lineattrs=(color=blue) legendlabel="Cases";
	yaxis label="7-Day Average Cases per 100,000" values=(0 to 500 by 50);
refline VAXX_25/ axis=x lineattrs=(thickness=1 color=green pattern=Dash) legendlabel="25% of Population Vaccinated" NAME="VAX25";
	refline VAXX_75/ axis=x lineattrs=(thickness=1 color=red pattern=Dash)legendlabel="75% of Population Vaccinated" NAME="VAX75";
refline SAH_begin/ axis=x lineattrs=(thickness=0.5 color=black pattern=ShortDash) legendlabel="Stay-at-Home Mandate Begins" NAME="SAHBEGIN";
	refline SAH_end/ axis=x lineattrs=(thickness=0.5 color=grey pattern=ShortDash)legendlabel="Stay-at-Home Mandate Ends" NAME="SAHEND";
refline MASK_begin/ axis=x lineattrs=(thickness=0.5 color=purple pattern=LongDash) legendlabel="Mask Mandate Begins" NAME="MASK1";
	refline MASK_end/ axis=x lineattrs=(thickness=0.5 color=pink pattern=LongDash) legendlabel="Mask Mandate Ends" NAME="MASK2";
keylegend "VAX25" "VAX75" "SAHBEGIN" "SAHEND" "MASK1" "MASK2";
run;

proc sgplot data=project;
	title "COVID-19 7-Day Average Cases in Florida Y20-22";
	where state="FL" and date ge MDY(1,1,2020) and date le MDY(1,31,2022);
	loess x=date y=CASE7/nomarkers lineattrs=(color=steel) legendlabel="Cases";
	yaxis label="7-Day Average Cases per 100,000" values=(0 to 500 by 50);
refline VAXX_25/ axis=x lineattrs=(thickness=1 color=green pattern=Dash) legendlabel="25% of Population Vaccinated" NAME="VAX25";
	refline VAXX_75/ axis=x lineattrs=(thickness=1 color=red pattern=Dash)legendlabel="75% of Population Vaccinated" NAME="VAX75";
refline SAH_begin/ axis=x lineattrs=(thickness=0.5 color=black pattern=ShortDash) legendlabel="Stay-at-Home Mandate Begins" NAME="SAHBEGIN";
	refline SAH_end/ axis=x lineattrs=(thickness=0.5 color=grey pattern=ShortDash)legendlabel="Stay-at-Home Mandate Ends" NAME="SAHEND";
refline MASK_begin/ axis=x lineattrs=(thickness=0.5 color=purple pattern=LongDash) legendlabel="Mask Mandate Begins" NAME="MASK1";
	refline MASK_end/ axis=x lineattrs=(thickness=0.5 color=pink pattern=LongDash) legendlabel="Mask Mandate Ends" NAME="MASK2";
keylegend "VAX25" "VAX75" "SAHBEGIN" "SAHEND" "MASK1" "MASK2";
run;


ods layout end;
