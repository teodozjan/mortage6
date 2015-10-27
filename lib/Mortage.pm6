use v6;

#| Converts percent to Rat
sub percent(Int $rate --> Rat) is export {
    Rat.new($rate,100);
}

#| Converts 12345 to 123.45 as Rat
sub money-in (Int $money --> Rat) is export {
    Rat.new($money,100);
}

#| Converts interest rate that is yearly
sub bigrate(Int $rate --> Rat) is export {
    #= Due to rat is not allowing double we use 
    #= following notation 4.04% is 404
    #= $rate / hundred / percent / months om year
    Rat.new($rate,120000);
}

#| Converts percents wrote without decimal separator
sub smallrate(Int $rate --> Rat) is export {
    Rat.new($rate,10000);
}
#| Mother interface for all costs
class AnnualCost{
    has Int $.from;
    has Int $.to;
    method get( $toPay,  $mortage) {!!!} 
}

#| Cost based on debt left
class AnnualCostPercentage is AnnualCost {
    has $.interest;
    method get( $toPay,  $mortage) { 
        return $toPay*$!interest;
    }
}

#| Cost based on monthly mortage installment
class AnnualCostMort is AnnualCost {
    has $.interest;
    method get( $toPay,  $mortage) {
        return $mortage*$!interest;
    }
}

#| Annual cost not basing on anything just constant value
class AnnualCostConst is AnnualCost {
    has  $.value;
    method get( $toPay,  $mortage)   {
        return $!value;
    }

}

#| Methods int this class don't round values unless specified.
#| Most common type is Rat that gives good enough precision.
#| Interest rates are stored in absolute value so 4% is 4/100
class Mortage {
    #TODO sparate input data from output data
    has Str $.currency; #= Currency, for gist 
    has Str $.bank; #= Bank name for gist
    has $.to_pay = Rat.new(297000,1); #= how much debt left
    has $.interest; #= Basic value for calculation of interest TODO rename to interest rate
    has Int $.mortages = 360; #= It is adjustable to comapare it with your bank calculations
    has $.mortage; #= The mony you pay monthly without other costs 
    has $.total_interest = Rat.new(0,1); #= total interest paid
    has $.total_cost = Rat.new(0,1); #total cost, including interest
    has AnnualCost @.costs; #= Costs list included in calculation

    #| Simulation runs here. Calculates all months. 
    method calc {
        #= Results are visible in B<gist> and $.total_cost, $.to_pay
        for 1 .. $!mortages -> $mort {            
           
            for @!costs -> $cost {
                if $mort >= $cost.from && $mort <= $cost.to {
                    $!total_cost += $cost.get($.to_pay, $.mortage); 
                }                
            }
           
            #TODO rename
            my $intests =  $!interest*$!to_pay;

            #say $mort, "  ",$intests.round(0.001), " ", $!to_pay.round(0.001);
            
            $!to_pay -= $!mortage;
            $!total_interest += $intests;
            $!to_pay +=  $intests;
            
            # Uncomment if want infltation
            #$!total_interest *= 1-Rat.new(200,$more_than_percent);
            }
    }
    
    #| Provides summary with value round
    method gist {
        return join "$!currency\n", $.bank,
        "Mortage " ~ $.mortage.round(0.01),
        "Balance: " ~ $.to_pay.round(0.01),
        "Basic interests: " ~ $.total_interest.round(0.01),
        "Other costs: " ~ $.total_cost.round(0.01),
        "Total cost: " ~ ($.total_cost+$.total_interest).round(0.01);
        # if correctly calculated $.to_pay should be close to 0
    }
    
    #| Will calculate mortage only pay. Without other costs.
    #| Value is rounded!
    method calc_mortage {
            my $c = $.interest;
            my $n = $.mortages;
            my $L = $.to_pay;
            my $my_mortage = ($L*($c*(1 + $c)**$n))/((1 + $c)**$n - 1);
            return $my_mortage.round(0.01);
    }

    #| Every cost is counted annualy so if you want to
    #| add one time cost just place it in correct month
    method add(AnnualCost $cost){
        @!costs.push($cost);
    }
    
    #| pay off debt
    method cash($cash){
        $!to_pay -= $cash;
    }
}
