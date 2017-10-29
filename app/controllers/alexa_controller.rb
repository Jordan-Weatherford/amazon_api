class AlexaController < ApplicationController
    require 'custom_caller'

    credentials = {
        'secret_key' => 'y7DmAv+5rJ+9IdZlkiUb/vzk731oAuAf6HxtoQlh',
        'key_id' => 'AKIAIY7NGC2K7ONJPBKA',
        'associate_tag' => 'ultralightpac-20'
    }
    @@request = CustomCaller.new
    @@request.config(credentials)


    def comparison_chart
        data = @@request.echo_chart

        render json: data
    end
end
