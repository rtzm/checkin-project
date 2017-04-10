module Githooker
  extend self

  def self.hook(hook_name, file_contents)
    return unacceptable_hook_exit_status unless acceptable_hooks.include? hook_name
    git_dir = find_git_dir
    return no_git_repo_found_exit_status unless git_dir
    return githook_already_exists_exit_status(hook_name) if githook_already_exists(git_dir, hook_name)
    hook_file = File.open(hook_full_path, "w") do |file|
      file_contents.each_line { |line| file.puts line }
    end
    system("chmod +x #{hook_full_path}")
    return "Added githook on hook #{hook_name}, located in hooks folder #{hooks_dir}"
  end

  private

  # find .git directory
  def find_git_dir
    if File.exist? ".git"
      return File.join(Dir.pwd,".git")
    else
      parent_dir_name = parent_dir_path
      if File.exist? parent_dir_name
        Dir.chdir(parent_dir_name) { find_git_dir }
      else
        return false
      end
    end
  end

  # find path to parent directory
  def parent_dir_path
    Dir.pwd[0...Dir.pwd.rindex(File::SEPARATOR)]
  end

  # check if .git/hooks contains file matching current hook
  def githook_already_exists?(git_dir, hook_name)
    hooks_dir = File.join(git_dir, "hooks")
    hook_full_path = File.join(hooks_dir, hook_name)
    File.exist? hook_full_path
  end

  def unacceptable_hook_exit_status
    exit_status = "Please provide an acceptable hook name. Acceptable hooks are as follows:\n"
    acceptable_hooks.each {|hook| exit_status += "  - '" + hook + "'\n"}
    exit_status += "Refer to git docs for more information.\n"
    return exit_status
  end

  def no_git_repo_found_exit_status
    "No git repository found... exiting... "
  end

  def githook_already_exists_exit_status(hook_name)
    "Githook for this action (#{hook_name}) already exists. This script is unable to manage duplicate executables for the same githook. Exiting..."
  end

  def acceptable_hooks
    ["applypatch-msg","pre-applypatch","post-applypatch","pre-commit","prepare-commit-msg","commit-msg","post-commit","pre-rebase","post-checkout","post-merge","pre-push","pre-receive","update","post-receive","post-update","push-to-checkout","pre-auto-gc","post-rewrite","rebase"]
  end
end
