'''
Example of a ONE_DONE script that will be called by RESim after it has
been initialized.  This one calls injectIO with parameters
found in OS environment variables set by the script that repeatdedly 
starts RESim.
'''
import os
global mytop, myinject
def quit(cycles=None):
    global mytop, myinject
    print('in onedoneTrack quit')
    myinject.saveJson()
    mytop.quit(cycles)

def reportExit():
    path=os.getenv('ONE_DONE_PATH')
    print('%s caused exit, crashed')
    quit()

def onedone(top):
    global mytop, myinject
    mytop=top
    path=os.getenv('ONE_DONE_PATH')
    outpath=os.getenv('ONE_DONE_PARAM')
    only_thread_s=os.getenv('ONE_DONE_PARAM2')
    only_thread = False 
    if only_thread_s is not None and only_thread_s.lower() == 'true':
        only_thread = True
    myinject = top.injectIO(path, save_json=outpath, callback=quit, go=False, only_thread=only_thread)
    myinject.setExitCallback(reportExit)
    myinject.go()


