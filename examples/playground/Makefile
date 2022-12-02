# check for build/shipkit and clone if not there, this should come first
SHIPKIT_DIR = ../..
# $(shell [ ! -e $(SHIPKIT_DIR) ] && git clone -b v2.0.11 https://github.com/yakworks/shipkit.git $(SHIPKIT_DIR) --depth=1 >/dev/null 2>&1)
# Shipkit.make first, which does all the lifting to create makefile.env for the BUILD_VARS
include $(SHIPKIT_DIR)/Shipkit.make

hello:
	echo Hello

# Auto Variable Examples. see docs/Makefiles.md
auto-vars: README.md foo.txt
	echo '$$@ = $@' # The name/filename representing the target.
	echo '$$% = $%' # The filename element of an archive member specification.
	echo '$$< = $<' # The name/filename of the first prerequisite.
	echo '$$? = $?' # The names of all prerequisites that are newer than the target, separated by spaces.
	echo '$$^ = $^' # The filenames of all the prerequisites, separated by spaces.

    # 2. `$%` - The filename element of an archive member specification.
    # 3. `$<` - The name/filename of the first prerequisite.
    # 4. `$?` - The names of all prerequisites that are newer than the target, separated by spaces.
    # 5. `$^` - The filenames of all the prerequisites, separated by spaces.
    #     This list has duplicate filenames removed since for most uses, such as compiling, copying, etc., duplicates are not wanted.
    # 6. `$+` - Similar to `$^`, this is the names of all the prerequisites separated by spaces, except that `$+` includes duplicates. This variable was created for specific situations such as arguments to linkers where duplicate values have meaning.
    # 7. `$*` - The stem of the target filename. A stem is typically a filename without its suffix.
    #           (We’ll discuss how stems are computed later in the section “Pattern Rules.”) Its
    #           use outside of pattern rules is discouraged.
