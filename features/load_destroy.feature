Feature: Eliminazione di Carichi
  In order to destroy a load 
  history of the following unloads should not go negative

  Scenario: Destroy load 
    Given one organization with thing
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-07
      And one load pluto of 12 in date 02-07
      And one unload unpippo of 12 in date 03-07
     When I destroy the load pippo
     Then I dont get error in base of load pippo
      And there is no more load pippo

  Scenario: Destroy load incoherent
    Given one organization with thing
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-07
      And one load pluto of 12 in date 02-07
      And one unload unpippo of 15 in date 03-07
     When I destroy the load pluto
     Then I get error in base of load pluto: non renda impossibili
      And date of pluto is 02-07

 
