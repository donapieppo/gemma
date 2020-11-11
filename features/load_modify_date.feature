Feature: Modifica della data di un carico
  In order to change the date of a previous load 
  history of the following unloads thing should not go negative

  Scenario: Modify Unload in correct way
    Given one organization with thing
      And one ddt in date 28-06
      And one load pippo of 10 in date 01-07
      And one load pluto of 12 in date 02-07
      And one unload unpippo of 15 in date 03-07
    When I change the date of pluto to 29-06
    Then I dont get error in base of load pluto
     And date of pluto is 29-06
 
  Scenario: Modify Unload incoherent day
    Given one organization with thing
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-07
      And one load pluto of 12 in date 02-07
      And one unload unpippo of 15 in date 03-07
    When I change the date of pluto to 04-07
    Then I get error in base of load pluto: non renda impossibili
     And date of pluto is 02-07

  Scenario: Modify Unload incoerent day with ddt
    Given one organization with thing
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-07
      And one load pluto of 12 in date 02-07
      And one unload unpippo of 15 in date 03-07
    When I change the date of pluto to 29-06
    Then I get error in date of load pluto: ddt
     And date of pluto is 02-07
 
 
 
 
