# coding: utf-8

"""
    OpenAPI Petstore

    This spec is mainly for testing Petstore server and contains fake endpoints, models. Please do not use this for any other purpose. Special characters: \" \\

    The version of the OpenAPI document: 1.0.0
    Generated by OpenAPI Generator (https://openapi-generator.tech)

    Do not edit the class manually.
"""  # noqa: E501


import unittest

from petstore_api.models.primitive_string import PrimitiveString

class TestPrimitiveString(unittest.TestCase):
    """PrimitiveString unit test stubs"""

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def make_instance(self, include_optional) -> PrimitiveString:
        """Test PrimitiveString
            include_optional is a boolean, when False only required
            params are included, when True both required and
            optional params are included """
        # uncomment below to create an instance of `PrimitiveString`
        """
        model = PrimitiveString()
        if include_optional:
            return PrimitiveString(
                value = ''
            )
        else:
            return PrimitiveString(
        )
        """

    def testPrimitiveString(self):
        """Test PrimitiveString"""
        # inst_req_only = self.make_instance(include_optional=False)
        # inst_req_and_optional = self.make_instance(include_optional=True)

if __name__ == '__main__':
    unittest.main()
