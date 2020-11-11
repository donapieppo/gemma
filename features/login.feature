Feature: Login with upn from a certain ip

  Scenario: upn from unknows ip
    Given organization pippo123
      And admin pippo.pluto in organization pippo123 with authlevel 10
    When he logs 
    Then he has a single organization to choose
     And he has autlevel 10 on organization pippo123
 
  Scenario: upn from unknows ip in multi organizations
    Given organization pippo123
      And organization pippo124
      And admin pippo.pluto in organization pippo123 with authlevel 10
      And admin pippo.pluto in organization pippo124 with authlevel 20
    When he logs 
    Then he has multiple organizations to choose
     And he has autlevel 10 on organization pippo123
     And he has autlevel 20 on organization pippo124
