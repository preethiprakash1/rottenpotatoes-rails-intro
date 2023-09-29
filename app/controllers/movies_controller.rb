class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @sort_based_on = params[:sort]

    if params[:ratings]
      @ratings_to_show = params[:ratings].keys
    else
      @ratings_to_show = @all_ratings
    end
  
    if (!params.has_key?(:ratings) && session.has_key?(:ratings_to_show_map) && !params.has_key?(:sort) && session.has_key?(:sort_based_on) && !params[:commit])
      redirect_to movies_path(:sort => session[:sort_based_on], :ratings => session[:ratings_to_show_map]) and return
    end

    if ((!params.has_key?(:ratings) && session.has_key?(:ratings_to_show_map)) && (!params.has_key?(:sort) && !session.has_key?(:sort_based_on)) && !params[:commit])
      redirect_to movies_path(:sort => "", :ratings => session[:ratings_to_show_map]) and return
    end

    if ((!params.has_key?(:ratings) && !session.has_key?(:ratings_to_show_map)) && (!params.has_key?(:sort) && session.has_key?(:sort_based_on)))
      redirect_to movies_path(:sort => session[:sort_based_on], :ratings => @all_ratings) and return
    end

    session[:sort_based_on] = @sort_based_on
    @ratings_to_show_map = @ratings_to_show.map { |value| [value, "1"] }.to_h
    session[:ratings] = params[:ratings]
    session[:ratings_to_show_map] = @ratings_to_show_map
    

    if @sort_based_on=="title"
      @highlight_setting_title = 'bg-warning hilite'
    elsif @sort_based_on=="release_date"
      @highlight_setting_release_date = 'bg-warning hilite'
    end
 
    @movies = Movie.with_ratings(@ratings_to_show).order(@sort_based_on)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end