Feature: Prezzi

  Scenario: When I make a load the price of the thing gets correct future_prices
   Given one organization with thing
      And organization has pricing on
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-07 with price 100
    Then future_prices of thing in load pippo has 10 at 10 euro in position 0

  Scenario: When I make a load in the past the future_prices have correct order
   Given one organization with thing
      And organization has pricing on
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-08 with price 200
      And one load pippo of 10 in date 01-07 with price 100
     Then future_prices of thing in load pippo has 10 at 10 euro in position 0
      And future_prices of thing in load pippo has 10 at 20 euro in position 1


  Scenario: When I make a load in the past and the sequent load is without price the lastprice change  
   Given one organization with thing
      And organization has pricing on
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-08 with price 0
      And one load pippo of 10 in date 01-07 with price 100
     Then future_prices of thing in load pippo has 2 elements
      And future_prices of thing in load pippo has 10 at 10 euro in position 0
      And future_prices of thing in load pippo has 10 at 0 euro in position 1
     

  Scenario: When I make a load and i change its number the future_prices change  
   Given one organization with thing
      And organization has pricing on
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-08 with price 100
     When I change the number of pippo to 5
     Then future_prices of thing in load pippo has 5 at 20 euro in position 0

  Scenario: When I make a load and i change its number the future_prices change
   Given one organization with thing
      And organization has pricing on
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-08 with price 100
     When I change the price of pippo to 50
     Then future_prices of thing in load pippo has 1 elements
      And future_prices of thing in load pippo has 10 at 5 euro in position 0

  Scenario: When I make a load and I delete it the lastprice change to 0
   Given one organization with thing
      And organization has pricing on
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-08 with price 100
     When I destroy the load pippo
     Then future_prices of thing in load pippo has 0 elements
 
