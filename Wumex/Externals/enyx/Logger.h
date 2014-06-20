#ifndef LOGGER_ENABLED
    #if (defined(DEBUG) && DEBUG)
        #define LOGGER_ENABLED 1
    #endif
#endif

#if (defined(LOGGER_ENABLED) && LOGGER_ENABLED)

#ifndef LOG_LEVEL_DEBUG
#define LOG_LEVEL_DEBUG	1
#endif

#ifndef LOG_LEVEL_INFO
#define LOG_LEVEL_INFO 1
#endif

#ifndef LOG_LEVEL_WARN
#define LOG_LEVEL_WARN 1
#endif

#ifndef LOG_LEVEL_ERROR
#define LOG_LEVEL_ERROR 1
#endif

#else

#undef LOG_LEVEL_DEBUG
#undef LOG_LEVEL_INFO
#undef LOG_LEVEL_WARN  
#undef LOG_LEVEL_ERROR

#endif //of LOGGER_ENABLED


#define LOG_FORMAT(lvl, fmt, ...) NSLog((@"[%@] " fmt), lvl, ##__VA_ARGS__)

#if defined(LOG_LEVEL_DEBUG) && LOG_LEVEL_DEBUG
#define LogD(fmt, ...) LOG_FORMAT(@"debug", fmt, ##__VA_ARGS__)
#else
#define LogD(fmt, ...)
#endif

#if defined(LOG_LEVEL_INFO) && LOG_LEVEL_INFO
#define LogI(fmt, ...) LOG_FORMAT(@"info", fmt, ##__VA_ARGS__)
#else
#define LogI(fmt, ...)
#endif

#if defined(LOG_LEVEL_WARN) && LOG_LEVEL_WARN
#define LogW(fmt, ...) LOG_FORMAT(@"warn", fmt, ##__VA_ARGS__)
#else
#define LogW(fmt, ...)
#endif

#if defined(LOG_LEVEL_ERROR) && LOG_LEVEL_ERROR
#define LogE(fmt, ...) LOG_FORMAT(@"error", fmt, ##__VA_ARGS__)
#else
#define LogE(fmt, ...)
#endif


//CUSTOM LOGGERS
//CGRect
#define vwLogRect(s, rect) LogD(@"(%@)CGRect(%f,%f,%f,%f)", s, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)

