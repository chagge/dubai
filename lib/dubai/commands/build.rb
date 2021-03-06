command :build do |c|
  c.syntax = 'pk build [PASSNAME]'
  c.summary = 'Creates a .pkpass archive'
  c.description = ''

  c.example 'description', 'pk archive mypass -o mypass.pkpass'
  c.option '-c', '--certificate /path/to/cert.pem', 'Pass certificate'
  c.option '-p', '--[no]-password', 'Prompt for certificate password'
  c.option '-o', '--output /path/to/out.pkpass', '.pkpass output filepath'

  c.action do |args, options|
    determine_directory! unless @directory = args.first
    validate_directory!

    @filepath = options.output || "#{@directory}.pkpass"
    validate_output_filepath!

    @certificate = options.certificate
    validate_certificate!

    @password = ask("Enter certificate password:"){|q| q.echo = false} if options.password

    Dubai::Passbook.certificate, Dubai::Passbook.password = @certificate, @password

    begin
      File.open(@filepath, 'w') do |f|
        f.write Dubai::Passbook::Pass.new(@directory).pkpass.string
      end
    rescue OpenSSL::PKCS12::PKCS12Error => error
      say_error "Error: #{error.message}"
      say_warning "You may be getting this error because the certificate password is either incorrect or missing"
      abort
    rescue => error
      say_error "Error: #{error.message}" and abort
    end
  end
end

alias_command :archive, :build
alias_command :b, :build

private

def validate_output_filepath!
  say_error "Filepath required" and abort if @filepath.nil? or @filepath.empty?
  say_error "#{@filepath} already exists" and abort if File.exist?(@filepath)
end
