/**
 * Sample for Array of Lists
 * No description provided (generated by Openapi Generator https://github.com/openapitools/openapi-generator)
 *
 * OpenAPI spec version: 1.0.0
 * 
 *
 * NOTE: This class is auto generated by OpenAPI Generator (https://openapi-generator.tech).
 * https://openapi-generator.tech
 * Do not edit the class manually.
 */

import { HttpFile } from '../http/http';

export class Pagination {
    /**
    * URL for the previous page
    */
    'prevUrl'?: string | null;
    /**
    * URL for the next page
    */
    'nextUrl'?: string | null;

    static readonly discriminator: string | undefined = undefined;

    static readonly mapping: {[index: string]: string} | undefined = undefined;

    static readonly attributeTypeMap: Array<{name: string, baseName: string, type: string, format: string}> = [
        {
            "name": "prevUrl",
            "baseName": "prevUrl",
            "type": "string",
            "format": "url"
        },
        {
            "name": "nextUrl",
            "baseName": "nextUrl",
            "type": "string",
            "format": "url"
        }    ];

    static getAttributeTypeMap() {
        return Pagination.attributeTypeMap;
    }

    public constructor() {
    }
}
