class Video < ApplicationRecord
  attr_accessor :encrypted_attachments
  
  after_initialize :set_encrypted_video_key
  
  after_initialize do
    self.encrypted_attachments ||= []
  end
  
  before_save do
    self.encrypted_video_key_will_change! if encrypted_video_key_changed?
  end   

  def set_encrypted_video_key
    self.encrypted_video_key ||= Lockbox.generate_key
  end  

  def encrypted_attachments=(files)
    if files.is_a?(Array)
      files.each do |file|
        process_attachment(file)
      end
    else
      process_attachment(files)
    end
  end  
  
  def process_attachment(file)
      if file.respond_to?(:read)
        begin
          # Define the directory to store encrypted video files
          external_video_directory = '/home/sravya/Videos/encrypted_videos/'
    
          # Ensure the directory exists, create it if necessary
          FileUtils.mkdir_p(external_video_directory) unless File.directory?(external_video_directory)
    
          # Generate a unique filename for the encrypted file
          encrypted_filename = file.original_filename
          # Create the full path for the encrypted video file
          encrypted_file_path = File.join(external_video_directory, encrypted_filename)
    
          # Ensure encrypted_video_key is set
          set_encrypted_video_key unless self.encrypted_video_key
    
          # Encrypt the file content
          lockbox = Lockbox.new(key: encrypted_video_key)
          encrypted_data = lockbox.encrypt(file.read)
    
          # Save the encrypted data to a new file in the external directory
          File.binwrite(encrypted_file_path, encrypted_data)
    
          # Set the attributes of the Video instance
          self.encrypted_file_path = encrypted_file_path
          self.original_file_name = file.original_filename
        rescue StandardError => e
          # Handle encryption errors
          puts "Encryption failed: #{e.message}"
          errors.add(:base, "Encryption failed: #{e.message}")
          return false
        end
      else
        # Handle case where file cannot be read
        puts "Unable to read file"
        errors.add(:base, "Unable to read file")
        return false
      end
  end


  def decrypted_video_url
    Rails.application.routes.url_helpers.decrypted_video_videos_path(id)
  end
end
