Feature: Modifica del numero di oggetti in un carico
  In order to diminish number of things from a previous load 
  history of the following unloads should not go negative

  Scenario: Modify Unload number correctly
    Given one organization with thing
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-07
      And one load pluto of 12 in date 02-07
      And one unload unpippo of 15 in date 03-07
     When I change the number of pluto to 5
     Then I dont get error in base of load pluto
      And number of pluto is 5
 
  Scenario: Modify Unload number incoherent with successive unloads
    Given one organization with thing
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-07
      And one load pluto of 12 in date 02-07
      And one unload unpippo of 15 in date 03-07
     When I change the number of pluto to 2
     Then I get error in base of load pluto:  non renda impossibili
      And number of pluto is 12

 
 
 
