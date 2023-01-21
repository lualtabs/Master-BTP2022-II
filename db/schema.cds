namespace com.logali;

type Name : String(50);

using {
    cuid,
    managed
} from '@sap/cds/common';


type Address {
    Street     : String;
    City       : String;
    State      : String(2);
    PostalCode : String(5);
    Country    : String(3);
};

//Requested entities

// *----------------------------------------------------------
// * Context materials
// *----------------------------------------------------------
context materials {

    entity Products : cuid, managed {
        //    key ID               : UUID;
        Name             : localized String not null;
        Description      : localized String;
        ImageUrl         : String;
        ReleaseDate      : DateTime default $now;
        DiscontinuedDate : DateTime;
        Price            : Decimal(16, 2);
        Height           : type of Price; //Decimal(16, 2);
        Width            : Decimal(16, 2);
        Depth            : Decimal(16, 2);
        Quantity         : Decimal(16, 2);
        Supplier         : Association to sales.Suppliers;
        UnitOfMeasure    : Association to UnitOfMeasure;
        Currency         : Association to Currencies;
        DimensionUnit    : Association to DimensionUnits;
        Category         : Association to Categories;
        SalesData        : Association to many sales.SalesData
                               on SalesData.Product = $self;
        Review           : Association to many ProductReview
                               on Review.Product = $self;
    };

    entity Categories : cuid {
        //    key ID   : String(1);
        Name : localized String;
    };

    entity StockAvailability : cuid {
        //    key ID          : Integer;
        Description : localized String;
        Product     : Association to Products;
    };

    entity Currencies : cuid {
        //    key ID          : String(3);
        Description : localized String;
    };

    entity UnitOfMeasure : cuid {
        //    key ID          : String(2);
        Description : localized String;
    }

    entity DimensionUnits : cuid {
        //    key ID          : String(2);
        Description : localized String;
    };

    entity ProductReview : cuid, managed {
        //    key ID      : UUID;
        Name    : String;
        Rating  : Integer;
        Comment : String;
        Product : Association to Products;
    };

    entity ProjProducts  as projection on Products;

    entity ProjProducts2 as projection on Products {
        *
    };

    entity ProjProducts3 as projection on Products {
        ReleaseDate,
        Name
    };

    extend Products with {
        PriceCondition     : String(2);
        PriceDetermination : String(3);
    };
}

// *----------------------------------------------------------
// * Context products
// *----------------------------------------------------------
context sales {

    entity Orders : cuid {
        //    key ID       : UUID;
        Date     : Date;
        Customer : String;
        Item     : Composition of many OrderItems
                       on Item.Orders = $self;
    };

    entity OrderItems : cuid {
        //    ID       : UUID;
        Orders   : Association to Orders;
        Products : Association to materials.Products;
        Quantity : Integer;
    };

    entity Suppliers : cuid, managed {
        //    key ID      : UUID;
        Name    : type of materials.Products : Name;
        Address : Address;
        Email   : String;
        Phone   : String;
        Fax     : String;
        Product : Association to materials.Products
                      on Product.Supplier = $self;
    };

    entity Months : cuid {
        //    key ID               : String(2);
        Description      : localized String;
        ShortDescription : String(3);
    };

    entity SelProducts  as select from materials.Products;

    entity SelProducts1 as
        select from materials.Products {
            *
        };

    entity SelProducts2 as
        select from materials.Products {
            Name,
            Price,
            Quantity
        };

    entity SelProducts3 as
        select from materials.Products
        left join materials.ProductReview
            on Products.Name = ProductReview.Name
        {
            Rating,
            Products.Name,
            sum(Price) as TotalPrice
        }
        group by
            Rating,
            Products.Name
        order by
            Rating;

    entity SalesData : cuid, managed {
        //    key ID            : UUID;
        DeliveryDate  : DateTime;
        Revenue       : Decimal(16, 2);
        Product       : Association to materials.Products;
        Currency      : Association to materials.Currencies;
        DeliveryMonth : Association to Months;
    };
}
