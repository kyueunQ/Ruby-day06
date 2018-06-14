class LottoController < ApplicationController
    
    def index
        @new_number = Lotto.last
        @new_number.class
        @numbers = Lotto.all
    end
    
    def new 
        number = (1..45).to_a.sample(6).sort
        lotto = Lotto.new
        lotto.numbers = number
        lotto.save
        redirect_to '/lotto'
    end
end
