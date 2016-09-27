#!/bin/sh

for site in /etc/drupal/8/sites/* ; do
	BASE_URL=""
	CRON_KEY=""
	FULL_URL=""

	if [ ! "`basename $site`" = "all" ]; then
		for file in $site/baseurl.php $site/settings.php; do
			[ -f "$file" ] && BASE_URL=`grep '^$base_url' $file | cut -d"'" -f2`
			[ "X$BASE_URL" != "X" ] && break
		done

		for file in $site/cronkey.php $site/settings.php; do
			[ -f "$file" ] && CRON_KEY=`grep '^$cron_key' $file | cut -d"'" -f2`
			[ "X$CRON_KEY" != "X" ] && break
		done

		if [ "X$BASE_URL" = "X" ] ; then
		        if [ -f "$site/settings.php" ]; then
			        BASE_URL='http://localhost/drupal8'
			else
			        break
			fi
		fi

		if [ "X$CRON_KEY" = "X" ] ; then
			FULL_URL="$BASE_URL/cron.php"
		else
			FULL_URL="$BASE_URL/cron.php?cron_key=$CRON_KEY"
		fi

		if curl -S --fail --silent --compressed --insecure --location $FULL_URL ; then
		        # Success!
		        true
		else
		        echo "Error running the periodic maintenance for $site: CURL exit code $?"
			echo "Requested URL: $FULL_URL"
		fi
	fi
done
