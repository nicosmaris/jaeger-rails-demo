
class SecondServiceController < ApplicationController
  def index
    # TODO: doing an external API call just to track it
    # TODO: doing an API call to the other component just to track it

    # doing a DB request just to track it
    Article.last

    render plain: 'OK from first component'
  end
end
