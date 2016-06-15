#import "HUBManager.h"

#import "HUBFeatureRegistryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBViewControllerFactoryImplementation.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBComponentDefaults.h"
#import "HUBComponentFallbackHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBManager ()

@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;

@end

@implementation HUBManager

- (instancetype)initWithConnectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
                           componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                         componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                               imageLoaderFactory:(nullable id<HUBImageLoaderFactory>)imageLoaderFactory
                                iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
                       defaultContentReloadPolicy:(nullable id<HUBContentReloadPolicy>)defaultContentReloadPolicy
                 prependedContentOperationFactory:(nullable id<HUBContentOperationFactory>)prependedContentOperationFactory
                  appendedContentOperationFactory:(nullable id<HUBContentOperationFactory>)appendedContentOperationFactory
{
    NSParameterAssert(connectivityStateResolver != nil);
    NSParameterAssert(componentLayoutManager != nil);
    NSParameterAssert(componentFallbackHandler != nil);
    
    self = [super init];
    
    if (self) {
        HUBComponentDefaults * const componentDefaults = [[HUBComponentDefaults alloc] initWithComponentNamespace:componentFallbackHandler.defaultComponentNamespace
                                                                                                    componentName:componentFallbackHandler.defaultComponentName
                                                                                                componentCategory:componentFallbackHandler.defaultComponentCategory];
        
        _connectivityStateResolver = connectivityStateResolver;
        _initialViewModelRegistry = [HUBInitialViewModelRegistry new];
        _featureRegistry = [HUBFeatureRegistryImplementation new];
        _componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:componentFallbackHandler];
        _JSONSchemaRegistry = [[HUBJSONSchemaRegistryImplementation alloc] initWithComponentDefaults:componentDefaults iconImageResolver:iconImageResolver];
        
        _viewModelLoaderFactory = [[HUBViewModelLoaderFactoryImplementation alloc] initWithFeatureRegistry:_featureRegistry
                                                                                        JSONSchemaRegistry:_JSONSchemaRegistry
                                                                                  initialViewModelRegistry:_initialViewModelRegistry
                                                                                         componentDefaults:componentDefaults
                                                                                 connectivityStateResolver:_connectivityStateResolver
                                                                                         iconImageResolver:iconImageResolver
                                                                          prependedContentOperationFactory:prependedContentOperationFactory
                                                                           appendedContentOperationFactory:appendedContentOperationFactory];
        
        _viewControllerFactory = [[HUBViewControllerFactoryImplementation alloc] initWithViewModelLoaderFactory:_viewModelLoaderFactory
                                                                                                featureRegistry:_featureRegistry
                                                                                              componentRegistry:_componentRegistry
                                                                                       initialViewModelRegistry:_initialViewModelRegistry
                                                                                         componentLayoutManager:componentLayoutManager
                                                                                     defaultContentReloadPolicy:defaultContentReloadPolicy
                                                                                             imageLoaderFactory:imageLoaderFactory];
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END