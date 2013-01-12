/*************************************************************************************************************************
                             CHL 5210 - Categorical Data Analysis 2007 
**************************************************************************************************************************
Course webpage:   http://www.biostats.ca/courseApp/WebPage/bio2004/new/learningcentre/coursematerials/chl5210.html
**************************************************************************************************************************
SAS SHORTCUT KEYS
F1 - help				F6 - Log		Ctrl+W - Explorer	Shift+F4/F5 - Tile/Cascade Windows
Ctrl+/ - Comment selected text		F7 - Output		Ctrl+B - Libraries	Alt+F4 - Close SAS
Ctrl+Tab - NEXTWIND command		F8 - Run selected				Ctrl+F4 - Close Window
**************************************************************************************************************************
Kate SHORTCUT KEYS
Ctrl+D - Comment Selected		Ctrl+F - Find		
Ctrl+Shift+D - Uncomment		Ctrl+R - Find and Replace
***************************************************************************************************************************/






/*Program generates one thousand Gamma values M with scale parameter lambda=1.5 */
/*and shape parameter C = 5. For each generated Gamma value M a Poisson count */
/*with mean M is randomly generated. The resulting distribution of counts is */
/*Negative Binomial with mean 3.333 = C x(lambda) and variance 5.556 generated */
/*directly using program 1. */
*** POISSONGAMMA *** ;  
OPTIONS PS = 65 LS = 100 NODATE NONUMBER ; 
DATA _NULL_ ; CALL SYMPUT('START',TIME()) ; RUN ; 
%LET C = 5 ; %LET RATE = 1.5 ; %LET N = 1000 ; 
%LET SEED = 16789 ; %LET CUT = 7 ; 
DATA POISSONGAMMA ; 
	MEANGAMMA = ROUND( ((&C) / (&RATE)), 0.001) ; 
	VARGAMMA = ROUND( ((&C) / (&RATE)** 2),0.001) ; 
	MEANNEGBIN = ROUND( ((&C) / (&RATE)), 0.001) ; 
	VARNEGBIN = ROUND( (MEANNEGBIN * ( 1 + (1/(&RATE)))), 0.001) ; 
	CALL SYMPUT('MEANGAMMA', MEANGAMMA ) ; CALL SYMPUT('VARGAMMA' ,VARGAMMA ) ; 
	CALL SYMPUT('MEANNEGBIN',MEANNEGBIN) ; CALL SYMPUT('VARNEGBIN',VARNEGBIN) ; 
	CALL STREAMINIT(&SEED) ; 
	DO I = 1 TO &N ; 
		GSTANDARD = RAND("GAMMA",&C) ; 
		M = GSTANDARD / &RATE ; 
		NCOUNT = RAND("POISSON", M ) ; 
		COUNTUNCUT = NCOUNT ; 
		IF NCOUNT GE &CUT THEN NCOUNT = &CUT ; 
			OUTPUT ; 
	END ; 
RUN ;
PROC PRINT DATA = POISSONGAMMA;
RUN;
%LET MEANGAMMA = &MEANGAMMA ; %LET VARGAMMA = &VARGAMMA ; 
%LET MEANNEGBIN = &MEANNEGBIN ; %LET VARNEGBIN = &VARNEGBIN ; 
TITLE1 "&N GAMMA RANDOM VALUES WITH C = &C AND RATE = &RATE"; 
TITLE2 "GAMMA : MEAN = &MEANGAMMA AND VARIANCE = &VARGAMMA"; 
TITLE3 "NEGATIVE BINOMIAL: MEAN = &MEANNEGBIN AND VARIANCE = &VARNEGBIN"; 
PROC MEANS DATA = POISSONGAMMA N MEAN VAR ; 
	VAR GSTANDARD M COUNTUNCUT NCOUNT ; 
RUN ; 
TITLE1 "DISTRIBUTION OF NEGATIVE BINOMIAL COUNTS WITH ARBITRARY CUT POINT = &CUT"; 
TITLE2 "NUMBER OF SAMPLES = &N MEAN = &MEANNEGBIN VARIANCE = &VARNEGBIN"; 
PROC FREQ DATA = POISSONGAMMA ; 
	TABLES NCOUNT / OUT = OUT3 ; 
RUN;
*View the discrete pmf and cdf of the negative binomial;
DATA PROBS ; 
	P = (&RATE) / (1 + (&RATE) ) ; 
	CALL SYMPUT('P',P) ; P = ROUND(P,0.01) ; 
	DO X = 0 TO &CUT ; 
		PCUM = CDF('NEGBINOMIAL',X,P,&C) ; 
		IF X = 0 THEN PROB = PCUM ; 
			IF X GT 0 THEN DO ; 
				PROB = CDF('NEGBINOMIAL',X,P,&C) - CDF('NEGBINOMIAL',X-1,P,&C) ; 
			END ; 
			IF X = &CUT THEN PROB = 1 - CDF('NEGBINOMIAL',X-1,P,&C) ; 
			OUTPUT ; 
		END ; 
RUN ; 
%LET P = &P ;  
TITLE1 'PROBABILITY DISTRIBUTION OF THE NEGATIVE BINOMIAL MODEL'; 
TITLE2 "C = &C AND P = &P USING ARBITRARY CUTPOINT OF &CUT"; 
PROC PRINT DATA = PROBS ; 
RUN ; 
PROC MEANS DATA = PROBS N SUM MEAN ; 
RUN ; 
*Pearson's chi-squared test, also known as the 
chi-squared goodness-of-fit test or chi-squared test for independence.
It tests a null hypothesis stating that the frequency distribution of certain 
events observed in a sample is consistent with a particular theoretical distribution;
DATA COMBO ; 
	MERGE OUT3 PROBS ; 
	EXP = PROB * (&N) ; 
	DIFF = (COUNT - EXP ) ; 
	CHI = (DIFF**2) / EXP ; 
RUN ; 
TITLE1 'DATASET COMBO' ; 
PROC PRINT DATA = COMBO ; 
RUN ; 

PROC MEANS N SUM ; 
	VAR CHI DIFF ; 
	OUTPUT OUT = OUT2 N = N SUM = SUMCHI SUMDIFF ; 
RUN ; 
DATA LAST ; 
	SET OUT2 ; 
	DF = N - 1 ; 
	P = 1 - PROBCHI(SUMCHI,DF) ; 
RUN ; 
TITLE1 'DATASET LAST'; 
PROC PRINT DATA = LAST ; 
RUN ; 
/****************** END OF PROGRAM ****************************************/ 
DATA _NULL_; 
	CALL SYMPUT('END', TIME()); 
RUN; 
DATA TIMER ; 
	START = &START ; 
	END = &END ; 
	DURATION = END - START ; 
RUN;
TITLE1 'TOTAL REAL EXECUTION TIME USING HOMEMADE PROGRAM'; 
PROC PRINT ; 
	VAR START END DURATION ; 
	FORMAT START END DURATION TIME8.; 
RUN ; 


