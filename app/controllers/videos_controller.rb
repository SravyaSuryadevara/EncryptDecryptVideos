class VideosController < ApplicationController
  # before_action :set_video, only: [:show]
  before_action :set_encrypted_video, only: [:select_encrypted_video]
 
  def new
   @video = Video.new
  end
  
  def create
    # Array to store the IDs of successfully saved videos
    saved_video_ids = []
  
    # Loop through each attachment
    params[:video][:encrypted_attachments].each do |file|
      # Create a new Video object
      @video = Video.new
  
      # Assign the current attachment to the encrypted_attachments attribute
      @video.encrypted_attachments = file
  
      # Attempt to save the Video object if original_file_name is present
      if @video.original_file_name.present?
        # If original_file_name is present, attempt to save the record
        if @video.save
          # If saved successfully, store the ID
          saved_video_ids << @video.id
        else
          # If save fails, render the new template and return early
          render :new and return
        end
      end
    end
  
    # Redirect to the select_encrypted_video action with the saved video IDs
    redirect_to select_encrypted_video_videos_path(selected_id: saved_video_ids)
  rescue ActiveRecord::RecordInvalid => e
    # Handle validation errors
    puts "Validation failed: #{e.message}"
    # Optionally, render an error page or redirect to an error route
    render plain: "Validation failed: #{e.message}", status: :unprocessable_entity
  rescue StandardError => e
    # Handle other errors
    puts "Error: #{e.message}"
    # Optionally, render an error page or redirect to an error route
    render plain: "Error: #{e.message}", status: :internal_server_error
  end  
 
  def show
    @video = Video.find(params[:id])
  end   
 
  def select_encrypted_video
   # @video = @videos.find(params[:selected_id])
  end
   
  def decrypted_video
    @video = Video.find(params[:id])
    lockbox = Lockbox.new(key: @video.encrypted_video_key)
  
    begin
      # Read encrypted file data
      encrypted_data = File.binread(@video.encrypted_file_path)
  
      # Decrypt the data
      decrypted_data = lockbox.decrypt(encrypted_data)
  
      # Respond with the decrypted data
      send_data decrypted_data, type: 'video/mp4', disposition: 'inline'
    rescue Lockbox::DecryptionError => e
      # Handle decryption errors
      puts "Decryption failed: #{e.message}"
      # Optionally, render an error page or redirect to an error route
      render plain: "Decryption failed: #{e.message}", status: :internal_server_error
    rescue StandardError => e
      # Handle other errors
      puts "Error: #{e.message}"
      # Optionally, render an error page or redirect to an error route
      render plain: "Error: #{e.message}", status: :internal_server_error
    end
  end     
       
  private
 
  def set_encrypted_video
   selected_ids = params[:selected_id] # assuming it's an array of video IDs
   @videos = Video.where(id: selected_ids)
  end
 
  def set_video
   @video = Video.find(params[:id])
  end
 
  def video_params
   params.require(:video).permit(:encrypted_file_path, :encrypted_file_name, encrypted_attachments: [])
  end   
 end