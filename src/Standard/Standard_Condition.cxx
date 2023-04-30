// Created by: Kirill Gavrilov
// Copyright (c) 2018 OPEN CASCADE SAS
//
// This file is part of Open CASCADE Technology software library.
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License version 2.1 as published
// by the Free Software Foundation, with special exception defined in the file
// OCCT_LGPL_EXCEPTION.txt. Consult the file LICENSE_LGPL_21.txt included in OCCT
// distribution for complete text of the license and disclaimer of any warranty.
//
// Alternatively, this file may be used under the terms of Open CASCADE
// commercial license or contractual agreement.

#ifdef _WIN32
#include <windows.h>
#elif !defined(OCCT_DISABLE_THREADS)
#include <pthread.h>
#include <unistd.h>
#include <errno.h>
#include <sys/time.h>
#endif

#include "Standard_Condition.hxx"

namespace
{
#ifndef _WIN32
#if !defined(OCCT_DISABLE_THREADS)
  //! clock_gettime() wrapper.
  static void conditionGetRealTime (struct timespec& theTime)
  {
  #if defined(__APPLE__)
    struct timeval aTime;
    gettimeofday (&aTime, NULL);
    theTime.tv_sec  = aTime.tv_sec;
    theTime.tv_nsec = aTime.tv_usec * 1000;
  #else
    clock_gettime (CLOCK_REALTIME, &theTime);
  #endif
  }
#endif
#endif
}

// =======================================================================
// function : Standard_Condition
// purpose  :
// =======================================================================
Standard_Condition::Standard_Condition (bool theIsSet)
#ifdef _WIN32
: myEvent((void* )::CreateEvent (0, true, theIsSet, NULL))
#else
: myFlag (theIsSet)
#endif
{
#ifndef _WIN32
#if !defined(OCCT_DISABLE_THREADS)
  pthread_mutex_init(&myMutex, 0);
  pthread_cond_init (&myCond,  0);
#else
  myMutex = 0;
  myCond = 0;
#endif
#endif
}

// =======================================================================
// function : ~Standard_Condition
// purpose  :
// =======================================================================
Standard_Condition::~Standard_Condition()
{
#ifdef _WIN32
  ::CloseHandle ((HANDLE )myEvent);
#else
#if !defined(OCCT_DISABLE_THREADS)
  pthread_mutex_destroy(&myMutex);
  pthread_cond_destroy (&myCond);
#endif
#endif
}

// =======================================================================
// function : Set
// purpose  :
// =======================================================================
void Standard_Condition::Set()
{
#ifdef _WIN32
  ::SetEvent ((HANDLE )myEvent);
#else
#if !defined(OCCT_DISABLE_THREADS)
  pthread_mutex_lock(&myMutex);
#endif
  myFlag = true;
#if !defined(OCCT_DISABLE_THREADS)
  pthread_cond_broadcast(&myCond);
  pthread_mutex_unlock  (&myMutex);
#endif

#endif
}

// =======================================================================
// function : Reset
// purpose  :
// =======================================================================
void Standard_Condition::Reset()
{
#ifdef _WIN32
  ::ResetEvent ((HANDLE )myEvent);
#else
#if !defined(OCCT_DISABLE_THREADS)
  pthread_mutex_lock (&myMutex);
#endif
  myFlag = false;
#if !defined(OCCT_DISABLE_THREADS)
  pthread_mutex_unlock (&myMutex);
#endif
#endif
}

// =======================================================================
// function : Wait
// purpose  :
// =======================================================================
void Standard_Condition::Wait()
{
#ifdef _WIN32
  ::WaitForSingleObject ((HANDLE )myEvent, INFINITE);
#else
#if !defined(OCCT_DISABLE_THREADS)
  pthread_mutex_lock (&myMutex);
  if (!myFlag)
  {
    pthread_cond_wait (&myCond, &myMutex);
  }
  pthread_mutex_unlock (&myMutex);
#endif
#endif
}

// =======================================================================
// function : Wait
// purpose  :
// =======================================================================
bool Standard_Condition::Wait (int theTimeMilliseconds)
{
#ifdef _WIN32
  return (::WaitForSingleObject ((HANDLE )myEvent, (DWORD )theTimeMilliseconds) != WAIT_TIMEOUT);
#else
  bool isSignalled = true;
#if !defined(OCCT_DISABLE_THREADS)
  pthread_mutex_lock (&myMutex);
  if (!myFlag)
  {
    struct timespec aNow;
    struct timespec aTimeout;
    conditionGetRealTime (aNow);
    aTimeout.tv_sec  = (theTimeMilliseconds / 1000);
    aTimeout.tv_nsec = (theTimeMilliseconds - aTimeout.tv_sec * 1000) * 1000000;
    if (aTimeout.tv_nsec > 1000000000)
    {
      aTimeout.tv_sec  += 1;
      aTimeout.tv_nsec -= 1000000000;
    }
    aTimeout.tv_sec  += aNow.tv_sec;
    aTimeout.tv_nsec += aNow.tv_nsec;
    isSignalled = (pthread_cond_timedwait (&myCond, &myMutex, &aTimeout) != ETIMEDOUT);
  }
  pthread_mutex_unlock (&myMutex);
#else
  (void)theTimeMilliseconds;
#endif
  return isSignalled;
#endif
}

// =======================================================================
// function : Check
// purpose  :
// =======================================================================
bool Standard_Condition::Check()
{
#ifdef _WIN32
  return (::WaitForSingleObject ((HANDLE )myEvent, (DWORD )0) != WAIT_TIMEOUT);
#else
  bool isSignalled = true;
#if !defined(OCCT_DISABLE_THREADS)
  pthread_mutex_lock (&myMutex);
  if (!myFlag)
  {
    struct timespec aNow;
    struct timespec aTimeout;
    conditionGetRealTime (aNow);
    aTimeout.tv_sec  = aNow.tv_sec;
    aTimeout.tv_nsec = aNow.tv_nsec + 100;
    isSignalled = (pthread_cond_timedwait (&myCond, &myMutex, &aTimeout) != ETIMEDOUT);
  }
  pthread_mutex_unlock (&myMutex);
#endif
  return isSignalled;
#endif
}

// =======================================================================
// function : CheckReset
// purpose  :
// =======================================================================
bool Standard_Condition::CheckReset()
{
#ifdef _WIN32
  const bool wasSignalled = (::WaitForSingleObject ((HANDLE )myEvent, (DWORD )0) != WAIT_TIMEOUT);
  ::ResetEvent ((HANDLE )myEvent);
  return wasSignalled;
#else
#if !defined(OCCT_DISABLE_THREADS)
  pthread_mutex_lock (&myMutex);
#endif
  bool wasSignalled = myFlag;
#if !defined(OCCT_DISABLE_THREADS)
  if (!myFlag)
  {
    struct timespec aNow;
    struct timespec aTimeout;
    conditionGetRealTime (aNow);
    aTimeout.tv_sec  = aNow.tv_sec;
    aTimeout.tv_nsec = aNow.tv_nsec + 100;
    wasSignalled = (pthread_cond_timedwait (&myCond, &myMutex, &aTimeout) != ETIMEDOUT);
  }
  myFlag = false;
  pthread_mutex_unlock (&myMutex);
#endif
  return wasSignalled;
#endif
}
