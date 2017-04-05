module Githooker
  def self.hook(hook_name, file_contents)
    git_dir = self.find_git_dir
    acceptable_hooks = ["applypatch-msg","pre-applypatch","post-applypatch","pre-commit","prepare-commit-msg","commit-msg","post-commit","pre-rebase","post-checkout","post-merge","pre-push","pre-receive","update","post-receive","post-update","push-to-checkout","pre-auto-gc","post-rewrite","rebase"]
    unless acceptable_hooks.include? hook_name
      puts "Please provide an acceptable hook name. Acceptable hooks are as follows:"
      acceptable_hooks.each {|hook| puts "  - '" + hook + "'"}
      puts "Refer to git docs for more information."
      exit(1)
    end

    if git_dir
      # check if .git/hooks contains file matching current hook
      hooks_dir = File.join(git_dir, "hooks")
      hook_full_path = File.join(hooks_dir, hook_name)
      unless File.exist? hook_full_path
        hook_file = File.open(hook_full_path, "w") do |file|
          file_contents.each_line { |line| file.puts line }
        end
        system("chmod +x #{hook_full_path}")
        puts "Added githook on hook #{hook_name}, located in hooks folder #{hooks_dir}"
      else
        puts "Githook for this action (#{hook_name}) already exists. This script is unable to manage duplicate executables for the same githook. Exiting..."
        exit(1)
      end
    else
      puts "No git repository found... exiting... "
      exit(1)
    end
  end

  def self.find_git_dir
    # find .git directory
    if File.exist? ".git"
      return File.join(Dir.pwd,".git")
    else
      # find path to parent directory
      index_of_parent_separator = Dir.pwd.rindex(File::SEPARATOR)
      parent_dir_name = Dir.pwd[0...index_of_parent_separator]

      if File.exist? parent_dir_name
        Dir.chdir(parent_dir_name) { self.find_git_dir }
      else
        return false
      end
    end
  end
end
