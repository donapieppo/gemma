Feature: date di unload uguale a data di load
  Given a load in date x an unload in date x is ok

  Scenario: Unload in same date as load
    Given one organization with thing
      And one ddt in date 28-06
      And one load pippo of 10 in date 01-07
      And one unload unpippo of 5 in date 01-07
 
