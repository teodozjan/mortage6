use v6;
use Test;
use Mortage;

plan 16;

class DBIWP is AnnualCostConst {
    has $.cumulation;
    has $.antiinterest;
    method get($toPay,$mortage){
        $!cumulation += 290;
        $!cumulation -= $!cumulation*$!antiinterest;
        return 10+$!cumulation*$!antiinterest;
    }
}

my $bank2 = Mortage.new(bank=>"BANK",interest_rate => rate-monthly(3.24), mortage => money-in(129093), mortages => 360, loan-left=> 297000);
# polisa
$bank2.add(AnnualCostConst.new(from=>1, to=>1, value=>$bank2.loan-left* smallrate(164)));
# Prowizja
$bank2.add(AnnualCostConst.new(from=>1, to=>1, value=>$bank2.loan-left * percent 1));
# ubezp
$bank2.add(AnnualCostMort.new(from=>25, to=>60, interest_rate => percent 4));
$bank2.add(AnnualCostConst.new(from=>1, to=>360, value => money-in 2145));

my $bank = Mortage.new(bank=>"BANK2",interest_rate => rate-monthly(3.30), mortage=> money-in(130073), mortages => 360, loan-left=> 297000);
# polisa
$bank.add(AnnualCostConst.new(from=>1, to=>1, value=>$bank.loan-left * smallrate 164));
# Prowizja
$bank.add(AnnualCostConst.new(from=>1, to=>1, value=>$bank.loan-left * percent 1));
# ubezp
$bank.add(AnnualCostMort.new(from=>25, to=>60, interest_rate => percent 4));
$bank.add(AnnualCostConst.new(from=>1, to=>360, value => money-in 2145));



my $bank3 = Mortage.new(bank=>"BANK3",interest_rate => rate-monthly(3.24), mortage=> money-in(129093), mortages => 360, loan-left=> 297000);
#POlisa DBIWP
$bank3.add(DBIWP.new(from=>1, to=>120,
                            cumulation=>$bank3.loan-left * smallrate(108),
                            antiinterest => percent 2));
$bank3.add(AnnualCostPercentage.new(from=>1, to=>12, interest_rate=> rate-monthly(-0.39)));
$bank3.add(AnnualCostPercentage.new(from=>25, to=>66, interest_rate => rate-monthly(0.20)));
$bank3.add(AnnualCostConst.new(from=>1, to=>360, value=>20));


is $bank.calc_mortage, money-in(130073),"Basic monthly";
is $bank2.calc_mortage, money-in(129093), "Basic monthly";
is $bank3.calc_mortage, money-in(129093),"Basic monthly";


$bank.calc;
$bank2.calc;
$bank3.calc;


is $bank.loan-left.round(0.01), -1.84, "Balance";
is $bank2.loan-left.round(0.01),2, "Balance";
is $bank3.loan-left.round(0.01),2, "Balance";

is $bank.total_cost.round(0.01),17435.85, "Other costs";
is $bank2.total_cost.round(0.01),17421.74, "Other costs";
is $bank3.total_cost.round(0.01),33445.19, "Other costs";

is $bank.total_interest.round(0.01),171260.96, "Total interests";
is $bank2.total_interest.round(0.01),167736.8, "Total interests";
is $bank3.total_interest.round(0.01),167736.8, "Total interests";

is percent(4),0.04, "Percent sub";
is money-in(12345), 123.45, "Money sub";
is rate-monthly(4.04),Rat.new(404,120000), "Rate-Monthly Sub";
is smallrate(101),Rat.new(101,10000);
