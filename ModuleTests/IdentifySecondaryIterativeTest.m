classdef IdentifySecondaryIterativeTest < matlab.unittest.TestCase
 
    methods(TestMethodSetup)
    end
 
    methods(TestMethodTeardown)
    end
    
    methods(Test)
        function handlesMatchC(testCase)
            
            dirTestsSub = 'State/IdentifySecondaryIterative';
            handlesIn = getTestHandlesUnchanged(dirTestsSub,'C/handles_in');
            handlesOut = getTestHandlesUnchanged(dirTestsSub,'C/handles_out');
            
            testResult = IdentifySecondaryIterative( handlesIn );
            testCase.verifyTrue( isequal(testResult, handlesOut) );
        end
    end
end