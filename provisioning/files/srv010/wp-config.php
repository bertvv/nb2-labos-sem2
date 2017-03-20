<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'wp_db');

/** MySQL database username */
define('DB_USER', 'wp_user');

/** MySQL database password */
define('DB_PASSWORD', 'CorkIgWac');

/** MySQL hostname */
define('DB_HOST', 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'P1+H/U!%/kg06bP+l^/hRP<QCEROH+fQ~)/cMPBTP]eRDc1_,]cX|GaB2@|D3;|N');
define('SECURE_AUTH_KEY',  '8a#v|qfLh 9sIcdJ6xQ4l{ S)]M%F;^hM.Z(&_L|^?j@A L1es j@?HNHm,RRQ|T');
define('LOGGED_IN_KEY',    '~88;*m!gk9RxWAefMDj[BrK +J[OYW8U}^-6 !=y-f@YDMc@-oT8Z(W]_Z*Hb6yq');
define('NONCE_KEY',        '(yXp%g4@tDrw`%Tk^*BK%i3&~<+W!Z{i,DlKz#ICZlRj!]:x.E.%uVa6q.Y>8fVA');
define('AUTH_SALT',        '<Qj-n#Up5Y+7!KE?|u-;|(j5L-(zo}|}%pHY2cM&,IacC9rmM&~`={|3om<-1A+:');
define('SECURE_AUTH_SALT', '~A8=D)QpeCS4KK}[~U8;`%Hrhn/MKSpmGFe< _HiE.clBPoQWkfhq;n3PBaSp5_a');
define('LOGGED_IN_SALT',   '5De{>z6_JKd+Ga0(g=!b?tjl*fX5=3|0u=<Z[O#;jP12qn.}3`*~_YB^)_&-*[v-');
define('NONCE_SALT',       'w<H^]:b@Iji*cc%?I09QnAoL0pkf7jld(]!_^uH?jJb09Q/9FD7N+tk^3+SZ^6V^');
/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * See http://make.wordpress.org/core/2013/10/25/the-definitive-guide-to-disabling-auto-updates-in-wordpress-3-7
 */

/* Disable all file change, as RPM base installation are read-only */
define('DISALLOW_FILE_MODS', true);

/* Disable automatic updater, in case you want to allow
   above FILE_MODS for plugins, themes, ... */
define('AUTOMATIC_UPDATER_DISABLED', true);

/* Core update is always disabled, WP_AUTO_UPDATE_CORE value is ignore */

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', '/usr/share/wordpress');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
