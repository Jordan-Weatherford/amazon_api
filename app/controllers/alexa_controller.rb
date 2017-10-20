class AlexaController < ApplicationController
    require 'custom_caller'

    credentials = {
        'secret_key' => '~~~~~~~~~~~~~~~~~~',
        'key_id' => '',
        'associate_tag' => 'ultralightpac-20'
    }
    @@request = CustomCaller.new
    @@request.config(credentials)


    def comparison_chart
        data = @@request.echo_chart

        render json: data
    end
end
