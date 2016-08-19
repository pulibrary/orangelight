module Orangelight
  module Catalog
    extend ActiveSupport::Concern

    def oclc
      redirect_to oclc_resolve(params[:id])
    end

    def isbn
      redirect_to isbn_resolve(params[:id])
    end

    def issn
      redirect_to issn_resolve(params[:id])
    end

    def lccn
      redirect_to lccn_resolve(params[:id])
    end

    def redirect_browse
      if params[:search_field] && params[:controller] != 'advanced'
        if params[:search_field] == 'browse_subject' && !params[:id]
          redirect_to "/browse/subjects?search_field=#{params[:search_field]}&q=#{CGI.escape params[:q]}"
        elsif params[:search_field] == 'browse_cn' && !params[:id]
          redirect_to "/browse/call_numbers?search_field=#{params[:search_field]}&q=#{CGI.escape params[:q]}"
        elsif params[:search_field] == 'browse_name' && !params[:id]
          redirect_to "/browse/names?search_field=#{params[:search_field]}&q=#{CGI.escape params[:q]}"
        end
      end
    end
  end
end
