#!/bin/bash
set -ev
if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
    echo $CI_GPG_KEY | base64 --decode >> /tmp/pgp_key;
    gpg --import /tmp/pgp_key;
    git config --global user.signingkey $CI_GPG_KEY_ID;
    
    bundle exec fastlane ci_release;
fi