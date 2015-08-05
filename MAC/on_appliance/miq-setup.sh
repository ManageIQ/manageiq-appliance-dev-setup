#!/bin/bash
. $SCRIPT_DIR/defines.sh

cd $MIQ_DIR || exit 1

# Update gems.
echo "**** Updating gems..."
bundle install --without qpid:metric_fu || exit 1
echo "**** done."
echo

# Migrate the database.
echo "**** Migrateing the database..."
bin/rake db:migrate || exit 1
echo "**** done."
echo

# Use the v2_key that's in the new source tree.
echo "**** Updating v2_key..."
bundle exec ./tools/fix_auth.rb --invalid smartvm --v2
bundle exec ./tools/fix_auth.rb --invalid smartvm --databaseyml
echo "**** done."
echo

# Precompile assets
echo "**** Precompiling assets..."
rake evm:compile_assets || exit 1
echo "**** done."
echo

exit 0
